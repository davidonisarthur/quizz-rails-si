export const HAND_LANDMARK_COUNT = 21

export const HAND_CONNECTIONS = [
  [ 0, 1 ], [ 1, 2 ], [ 2, 3 ], [ 3, 4 ],
  [ 0, 5 ], [ 5, 6 ], [ 6, 7 ], [ 7, 8 ],
  [ 5, 9 ], [ 9, 10 ], [ 10, 11 ], [ 11, 12 ],
  [ 9, 13 ], [ 13, 14 ], [ 14, 15 ], [ 15, 16 ],
  [ 13, 17 ], [ 0, 17 ], [ 17, 18 ], [ 18, 19 ], [ 19, 20 ]
]

export const FINGER_LANDMARKS = {
  index: [ 5, 6, 7, 8 ],
  middle: [ 9, 10, 11, 12 ],
  ring: [ 13, 14, 15, 16 ],
  pinky: [ 17, 18, 19, 20 ]
}

export const WRIST = 0
export const MIDDLE_MCP = 9
