bool isOnBoard(int x, int y) {
  return x >= 0 && x < 8 && y >= 0 && y < 8;
}

int matchTime(int timeLimit) {
  switch (timeLimit) {
    case 0:
      return 0;
    case 1:
      return 10;
    case 2:
      return 15;
    case 3:
      return 30;

    default:
      return 0;
  }
}
