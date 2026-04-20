#!/usr/bin/env python3
import argparse
import yaml
import numpy as np
from pathlib import Path
from rosbags.rosbag2 import Reader, Writer
from rosbags.typesys import Stores, get_typestore

def load_camera_info(yaml_path):
    """Loads camera parameters from a standard ROS camera_info.yaml file."""
    with open(yaml_path, 'r') as file:
        return yaml.safe_load(file)

def main():
    # --- COMMAND LINE ARGUMENTS ---
    parser = argparse.ArgumentParser(description="Bake CameraInfo messages into a ROS 2 bag based on a YAML file.")
    parser.add_argument('-i', '--input', required=True, help="Path to the input rosbag directory.")
    parser.add_argument('-o', '--output', required=True, help="Path for the new output rosbag directory.")
    parser.add_argument('-y', '--yaml', required=True, help="Path to the camera_info.yaml file.")
    parser.add_argument('--image-topic', default='/trig/image_raw', help="Image topic to trigger off of (default: /trig/image_raw).")
    parser.add_argument('--info-topic', default='/trig/camera_info', help="CameraInfo topic to publish to (default: /trig/camera_info).")
    
    args = parser.parse_args()

    # Load YAML data
    try:
        cam_data = load_camera_info(args.yaml)
    except Exception as e:
        print(f"Error loading YAML file {args.yaml}: {e}")
        return

    # Load the ROS 2 Humble type store (works for Foxy/Galactic/Iron/Jazzy)
    typestore = get_typestore(Stores.ROS2_HUMBLE)
    CameraInfo = typestore.types['sensor_msgs/msg/CameraInfo']
    RegionOfInterest = typestore.types['sensor_msgs/msg/RegionOfInterest']

    input_path = Path(args.input)
    output_path = Path(args.output)

    if not input_path.exists():
        print(f"Error: Input bag '{input_path}' does not exist.")
        return
    if output_path.exists():
        print(f"Error: Output bag '{output_path}' already exists. Please choose a new name.")
        return

    with Reader(input_path) as reader, Writer(output_path, version=8) as writer:
        
        # 1. Recreate all existing connections in the new bg
        conn_map = {}
        for conn in reader.connections:
            conn_map[conn.id] = writer.add_connection(
                conn.topic, conn.msgtype, typestore=typestore
            )
            
        # 2. Add a new connection for our injected CameraInfo topic
        info_conn = writer.add_connection(
            args.info_topic, 'sensor_msgs/msg/CameraInfo', typestore=typestore
        )

        print(f"Reading from {args.input} and writing to {args.output}...")
        print(f"Triggering on {args.image_topic}, writing to {args.info_topic}")
        
        info_count = 0
        for connection, timestamp, rawdata in reader.messages():
            
            # Write the original message to the new bag unmodified
            writer.write(conn_map[connection.id], timestamp, rawdata)
            
            # If we hit an image, generate and bake the CameraInfo
            if connection.topic == args.image_topic:
                # Deserialize the image to steal its exact header
                image_msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                
                # Create the CameraInfo message, converting lists to float64 numpy arrays!
                cam_info_msg = CameraInfo(
                    header=image_msg.header, 
                    height=cam_data['image_height'],
                    width=cam_data['image_width'],
                    distortion_model=cam_data['distortion_model'],
                    d=np.array(cam_data['distortion_coefficients']['data'], dtype=np.float64),
                    k=np.array(cam_data['camera_matrix']['data'], dtype=np.float64),
                    r=np.array(cam_data['rectification_matrix']['data'], dtype=np.float64),
                    p=np.array(cam_data['projection_matrix']['data'], dtype=np.float64),
                    binning_x=0,
                    binning_y=0,
                    roi=RegionOfInterest(x_offset=0, y_offset=0, height=0, width=0, do_rectify=False)
                )
                
                # Serialize and write the new info message
                info_rawdata = typestore.serialize_cdr(cam_info_msg, 'sensor_msgs/msg/CameraInfo')
                writer.write(info_conn, timestamp, info_rawdata)
                info_count += 1

        print(f"Done! Baked {info_count} CameraInfo messages into '{args.output}'.")

if __name__ == '__main__':
    main()
