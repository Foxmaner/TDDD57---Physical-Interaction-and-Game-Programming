
import cv2
import mediapipe as mp
import time
import json 
import asyncio
from google.protobuf.json_format import MessageToJson

#To senda data to broadcast server that GODOT listens to
import ws_client


# Init FaceMesh
mp_face_detection = mp.solutions.face_detection
mp_drawing = mp.solutions.drawing_utils

cap = cv2.VideoCapture(0)  
prevTime = 0
print(f'Reading from camera ')

# For webcam input:
cap = cv2.VideoCapture(0)
with mp_face_detection.FaceDetection(
    model_selection=0, min_detection_confidence=0.5) as face_detection:
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
    results = face_detection.process(image)

    # Draw the face detection annotations on the image.
    image.flags.writeable = True
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

    if results.detections:
      data = {}
      for detection in results.detections:
        msg = MessageToJson(detection)
        msg2 = {"Type": "FACE_DETECT", "DATA": json.loads(msg)}
        msg = json.dumps(msg2)
        try:
#          print(msg)
          asyncio.run(ws_client.send(msg))
        except ConnectionRefusedError:
          print('WS Server is down')

        mp_drawing.draw_detection(image, detection)
    
    currTime = time.time()
    fps = 1 / (currTime - prevTime)
    prevTime = currTime
    # Flip the image horizontally for a selfie-view display.
    cv2.putText(image, f'FPS: {int(fps)}', (20, 70), cv2.FONT_HERSHEY_PLAIN, 3, (0, 196, 255), 2)
    cv2.imshow('MediaPipe Face Detection', image)
    if cv2.waitKey(5) & 0xFF == 27:
      break
cap.release()
