########################
# This code takes requests from a socket connection and sends hardware info from WMI as a response.
# OpenHardwareMonitor must be running for many of these requests to return valid results. It takes
# OHM reads temp and load data from hardware and reports it to WMI.
########################

import socket
import time
import wmi
import struct

global_wmi_val = wmi.WMI(namespace="root\OpenHardwareMonitor")
currTime = time.time()

HOST = 'localhost'
PORT = 50007


def main():
    # instantiate a socket object
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print('socket instantiated')

    # bind the socket
    sock.bind((HOST, PORT))
    print('socket binded')

    # start the socket listening
    sock.listen()
    print('socket now listening')

    # accept the socket response from the client, and get the connection object
    conn, addr = sock.accept()      # Note: execution waits here until the client calls sock.connect()
    print('socket accepted, got connection object')
    

    while True:
        """Main loop."""
        message = receive_data_via_socket(conn)
        if message is not None:
            outgoing = respond_to_query(message)
            
            print("Received \"{}\"".format(message))
            if outgoing is not None:
                # print("Sending Data \"{}\"".format(outgoing))
                send_text_via_socket(outgoing, conn)



def respond_to_query(message):
    """Takes in a query message (probably from socket connection) and returns associated raw sensor data.
    This sensor data is unique to the hardware this code is running on and must be customized for each system."""
    if(message == "CPUTEMP"):
        return get_sensor_data('Temperature', 'Temperature #1')
    
    elif(message == "GPUTEMP"):
        return get_sensor_data('Temperature', 'GPU Core')

    elif(message == "GPULOAD"):
        return get_sensor_data('Load', 'GPU Core')


def get_sensor_data(sensorType, sensorName):
    """Requests sensor data from WMI and returns raw value or 'None' if no matching value is found."""
    global global_wmi_val
    temperature_infos = global_wmi_val.Sensor()
    for sensor in temperature_infos:
        if sensor.SensorType == sensorType:
            if sensor.name == sensorName:
                return sensor.Value
    return None


def receive_data_via_socket(sock):
    """Takes in 1024 bytes of data (maximum) from socket and attempts to parse as utf-8 and return.
    Since these data are polled asynchronously care must be taken to avoid receiving multiple messages simultaneously."""
    encoded_ack_text = sock.recv(1024)
    ack_text = encoded_ack_text.decode('utf-8')
    return ack_text


def send_text_via_socket(message, sock):
    """Sends a message to specified socket encoded as utf-8."""
    message = str(message)
    encoded_message = bytearray(message, 'utf-8')
    sock.sendall(encoded_message)
    


if __name__ == '__main__':
    main()

