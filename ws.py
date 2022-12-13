import asyncio 
import websockets 
import json 
import cv2
import mediapipe as mp

mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands

def get_data():
	if cap.isOpened():
		print("Oi")
		success, image = cap.read()
		if not success:
			# If loading a video, use 'break' instead of 'continue'.
			return "Ignoring empty camera frame."
		print("Oi2")

		# To improve performance, optionally mark the image as not writeable to
		# pass by reference.
		image.flags.writeable = False
		image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
		results = hands.process(image)

		# Draw the hand annotations on the image.
		image.flags.writeable = True
		image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
		res = ""
		if results.multi_hand_landmarks:
			res = json.dumps(results.multi_hand_landmarks)
		print(results.multi_hand_landmarks)
		if results.multi_hand_landmarks:
			for hand_landmarks in results.multi_hand_landmarks:
				mp_drawing.draw_landmarks(
					image,
					hand_landmarks,
					mp_hands.HAND_CONNECTIONS,
					mp_drawing_styles.get_default_hand_landmarks_style(),
					mp_drawing_styles.get_default_hand_connections_style())
		# Flip the image horizontally for a selfie-view display.
		cv2.imshow('MediaPipe Hands', cv2.flip(image, 1))
		return res


async def server(ws, path): 
	async for msg in ws: 
		msg = msg.decode("utf-8")
		print(f"Msg from client: {msg}")
		result = get_data()
		print(result)
		await ws.send(result)


cap = cv2.VideoCapture(0)
hands = mp_hands.Hands(
	model_complexity=0,
	min_detection_confidence=0.5,
	min_tracking_confidence=0.5)

start_server = websockets.serve(server, "localhost", 5000)
print("Server started")

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
