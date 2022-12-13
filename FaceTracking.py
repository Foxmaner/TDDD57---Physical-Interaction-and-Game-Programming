
import cv2
import mediapipe as mp
import time
import json 
import asyncio
import ws_client

# Init FaceMesh
mp_drawing = mp.solutions.drawing_utils
mp_face_mesh = mp.solutions.face_mesh
drawing_spec = mp_drawing.DrawingSpec(thickness=1, circle_radius=1)

cap = cv2.VideoCapture(0)  
prevTime = 0
print(f'Reading from camera ')

# Read video input
with mp_face_mesh.FaceMesh(
    max_num_faces=1,
    refine_landmarks=True, # for iris. False would return only 468 landmarks
    min_detection_confidence=0.5, 
    min_tracking_confidence=0.5) as face_mesh:
  while cap.isOpened():
    success, image = cap.read()
    if not success:
      continue 

    # Flip the image horizontally for a later selfie-view display, and convert
    # the BGR image to RGB.
#    image = cv2.cvtColor(cv2.flip(image, 1), cv2.COLOR_BGR2RGB)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    # To improve performance, optionally mark the image as not writeable to
    # pass by reference.
    image.flags.writeable = False
    results = face_mesh.process(image)

    # Draw the face mesh annotations on the image.
    image.flags.writeable = True
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
    
    img_h, img_w, img_c = image.shape

    if results.multi_face_landmarks:
      for face_landmarks in results.multi_face_landmarks:
        keypoints = []
        for data_point in face_landmarks.landmark:
          keypoints.append({
                          'X': data_point.x,
                          'Y': data_point.y,
                          'Z': data_point.z,
                          'Visibility': data_point.visibility,
                          })

        msg = json.dumps(keypoints)
        # Send data to ws server
        try:
          asyncio.run(ws_client.send(msg))
        except ConnectionRefusedError:
          print('WS Server is down')

        # Draw landmarks and connections
        mp_drawing.draw_landmarks(
            image=image,
            landmark_list=face_landmarks,
            connections=mp_face_mesh.FACEMESH_LIPS,
            landmark_drawing_spec=drawing_spec,
            connection_drawing_spec=drawing_spec) 

    currTime = time.time()
    fps = 1 / (currTime - prevTime)
    prevTime = currTime

    cv2.putText(image, f'FPS: {int(fps)}', (20, 70), cv2.FONT_HERSHEY_PLAIN, 3, (0, 196, 255), 2)
    cv2.imshow('MediaPipe FaceMesh', image)
    if cv2.waitKey(5) & 0xFF == 27:
      break

cap.release
