#!/usr/bin/env python3
import argparse
import numpy as np
from pathlib import Path
from rosbags.rosbag2 import Reader, Writer
from rosbags.typesys import Stores, get_typestore

def main():
    parser = argparse.ArgumentParser(description="Convert bgr8 images to rgb8 in a ROS 2 bag.")
    parser.add_argument('-i', '--input', required=True, help="Path to the input rosbag directory.")
    parser.add_argument('-o', '--output', required=True, help="Path for the new output rosbag directory.")
    parser.add_argument('--topic', default='/trig/image_raw', help="The image topic to target for conversion.")
    
    args = parser.parse_args()

    typestore = get_typestore(Stores.ROS2_HUMBLE)
    
    input_path = Path(args.input)
    output_path = Path(args.output)

    if not input_path.exists():
        print(f"Error: Input bag '{input_path}' does not exist.")
        return
    if output_path.exists():
        print(f"Error: Output bag '{output_path}' already exists. Please choose a new name.")
        return

    # Using version=8 for standard ROS 2 Humble/Iron bags
    with Reader(input_path) as reader, Writer(output_path, version=8) as writer:
        
        # Recreate all existing connections
        conn_map = {}
        for conn in reader.connections:
            conn_map[conn.id] = writer.add_connection(
                conn.topic, conn.msgtype, typestore=typestore
            )

        print(f"Reading from {args.input} and writing to {args.output}...")
        print(f"Scanning topic '{args.topic}' for bgr8 images...")
        
        converted_count = 0
        skipped_count = 0
        
        for connection, timestamp, rawdata in reader.messages():
            
            # If we are on the target image topic, inspect the message
            if connection.topic == args.topic:
                image_msg = typestore.deserialize_cdr(rawdata, connection.msgtype)
                
                if image_msg.encoding == 'bgr8':
                    # 1. Convert flat byte array to HxWx3 Numpy array
                    img_array = np.frombuffer(image_msg.data, dtype=np.uint8).reshape((image_msg.height, image_msg.width, 3))
                    
                    # 2. Swap the Blue (0) and Red (2) channels
                    rgb_array = img_array[:, :, ::-1].copy()
                    
                    # 3. Overwrite the message data and encoding flag
                    # CRITICAL FIX: Keep as a 1D numpy array instead of standard Python bytes!
                    image_msg.data = rgb_array.flatten()
                    image_msg.encoding = 'rgb8'
                    
                    # 4. Reserialize the modified message
                    rawdata = typestore.serialize_cdr(image_msg, connection.msgtype)
                    converted_count += 1
                else:
                    skipped_count += 1
            
            # Write the rawdata (whether modified or original) to the new bag
            writer.write(conn_map[connection.id], timestamp, rawdata)

        print("--- Conversion Complete ---")
        print(f"Converted {converted_count} 'bgr8' images to 'rgb8'.")
        if skipped_count > 0:
            print(f"Skipped {skipped_count} images that were not 'bgr8'.")

if __name__ == '__main__':
    main() 
