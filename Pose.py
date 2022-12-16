
import cv2
import mediapipe as mp
import time
import json 
import asyncio
from google.protobuf.json_format import MessageToJson

#To senda data to broadcast server that GODOT listens to
import ws_client


mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_pose = mp.solutions.pose

cap = cv2.VideoCapture(0)  
prevTime = 0
print(f'Reading from camera -- Pose ')

# For webcam input:
with mp_pose.Pose(
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5) as pose:
  while cap.isOpened():
    success, image = cap.read()
    if not success:
      print("Ignoring empty camera frame.")
      # If loading a video, use 'break' instead of 'continue'.
      continue

    # To improve performance, optionally mark the image as not writeable to
    # pass by reference.
    image.flags.writeable = False
    image = cv2.flip(image, 1)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = pose.process(image)

    # Draw the pose annotation on the image.
    image.flags.writeable = True
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
    if results.pose_landmarks: 
        msg = MessageToJson(results.pose_landmarks)
        #How to get more than one hand ...
        try:
#          print(msg)
          asyncio.run(ws_client.send(msg))
        except ConnectionRefusedError:
          print('WS Server is down')

              
        mp_drawing.draw_landmarks(
            image,
            results.pose_landmarks,
            mp_pose.POSE_CONNECTIONS,
            landmark_drawing_spec=mp_drawing_styles.get_default_pose_landmarks_style())
        
    # Flip the image horizontally for a selfie-view display.
    currTime = time.time()
    fps = 1 / (currTime - prevTime)
    prevTime = currTime
#    print(fps)
    cv2.putText(image, f'FPS: {int(fps)}', (20, 70), cv2.FONT_HERSHEY_PLAIN, 3, (0, 196, 255), 2)
    cv2.imshow('MediaPipe Pose', image)
    if cv2.waitKey(5) & 0xFF == 27:
      break
cap.release()