// My first programming project.
// First fully working version was done in 2018, added comments and refactored a bit in 2021.

// Number of cells in a row/column.
int cellCount = 10; 

// Size of one cell in pixels.
int cellSize = 800/cellCount;

// The number of mines on the board.
int mineCount = 10;

// Shows if the player has pressed on the mine and lost the game.
boolean hasLost = false;

// Used for saving the amount of time which has passed between opening the game and starting it.
int startTime;

// Used for saving the time when the game ends.
int endTime;

// Mine marker on the board.
final int MINE = -1;

private final Model model = new Model(mineCount);
private final View view = new View();

// The starting values are initialised in setup.
public void setup() {
  // The size of the game window is 800x800 pixels.
  size(800, 900);
  textSize(45);
  background(255);
  cellSize = 800/cellCount;
  startTime = -1;
  endTime = -1;
}

// This is the main game cycle. 
// It constantly repeats and updates the game screen.
public void draw() {
  background(255);
  view.drawCellBorders();
  if (!hasLost) {
    // only some cells are displayed.
    view.drawBoard(model.getBoard(), model.getDisplaying(), model.getFlagged());
  } else {
    // full board is displayed.
    view.drawBoard(model.getBoard(), model.getFlagged());
  }
  view.displayBottom(startTime, endTime);
}

// Controls the data flow for each mouse button pressed.
public void mousePressed() {
  int mouseRow = mouseX/cellSize;
  int mouseCol = mouseY/cellSize;
  
  if (startTime == -1) {
    startTime = millis();
  }
  
  if (mouseButton == LEFT) {
    LeftPressed(mouseRow, mouseCol);
  }
  
  if (mouseButton == RIGHT) {
    RightPressed(mouseRow, mouseCol);
  }
}

private void LeftPressed(int row, int col) {
  // The cell must be unflagged, otherwise nothing is done.
  if (!model.isFlagged(row, col)){
    model.setDisplaying(row, col);
    int value = model.getBoardCell(row, col);
    if (value == 0) {
      model.findOpen(row, col);
    } else if (value == MINE) {
      hasLost = true;
      endTime = millis();
    }
  }
}

private void RightPressed(int row, int col) {
  if (!model.isCellDisplayed(row, col) && !hasLost) {
    model.changeFlagState(row, col);
  }
}

// Contains all game logic.
class Model {
  
  // saves board data including the mine counts around the cell
  // and also the mine positions
  private int[][] board;
  
  // mine markers on the board
  //private final int MINE = -1;
  
  // used for saving cells which are being displayed
  private boolean[][] displaying;
  
  // the number of mines on the game board
  private int mineCount;
  
  // used for saving visited cells when opening large empty areas with recursion
  private boolean[][] visited;
  
  // used for saving flagged cells
  private boolean[][] flagged;
  
  public Model(int mineCount) {
    board = new int[cellCount][cellCount];
    displaying = new boolean[cellCount][cellCount];
    visited = new boolean[cellCount][cellCount];
    flagged = new boolean[cellCount][cellCount];
    this.mineCount = mineCount;
    generateMines();
    findCellNumbers(cellCount);
  }
  
  // Finds the number of mines around each cell in the board
  // Ignores the mine cells
  public void findCellNumbers(int cellCount) {
    for (int i=0; i<cellCount; i++) {
      for (int j=0; j<cellCount; j++) {
        if (board[i][j] != MINE) {
          board[i][j] = findMinesAround(i, j);
        }
      }
    }
  }
  
  // Finds the number of mines around a cell in the given coordinates
  private int findMinesAround(int row, int col) {
    int count = 0;
    if ((checkCell(row - 1, col - 1))) count++;
    if ((checkCell(row - 1, col))) count++;
    if ((checkCell(row - 1, col + 1))) count++;
    if ((checkCell(row, col - 1))) count++;
    if ((checkCell(row, col + 1))) count++;
    if ((checkCell(row + 1, col - 1))) count++;
    if ((checkCell(row + 1, col))) count++;
    if ((checkCell(row + 1, col + 1))) count++;
    return count;
  }
  
  // Checks if the cell is a mine cell
  private boolean checkCell(int row, int col) {
    // input validation
    if (inRange(row, col)) {
      return board[row][col] == MINE;
    } else return false;
  }
  
  // Opens the tiles around the given cell
  // Opens the tiles around surrounding 0 value (empty) cells
  // Used when the user finds a cell with 0 value (empty)
  public void findOpen(int row, int col) { //<>//
    // input validation
    if (!inRange(row, col)) return;
    visited[row][col] = true;
    for (int i = row - 1; i <= row + 1; i++) {
      for (int j = col - 1; j <= col + 1; j++) {
        if (inRange(i, j)) {
          setDisplaying(i, j);
          if (board[i][j] == 0 && !visited[i][j]) findOpen(i, j);
        }
      }
    }
  }

  // Validates the given cell coordinates
  public boolean inRange(int row, int col) {
    if (row < 0 || row > cellCount - 1) return false;
    if (col < 0 || col > cellCount - 1) return false;
    return true;
  }
  
  // Sets the cell to be displayed on the screen
  public void setDisplaying(int row, int col) {
    // input validation
    if (inRange(row, col)) {
      displaying[row][col] = true;
    }
  }
  
  // Generates and sets random positions for mines on the board
  // If a generated position has a mine already, another position is found
  private void generateMines() {
    int mineRow, mineCol;
    for (int i=0; i<mineCount; i++) {
      mineRow = (int) random(0, cellCount);
      mineCol = (int) random(0, cellCount);
      if (board[mineRow][mineCol] != MINE) {
        board[mineRow][mineCol] = MINE;
      }
      else i--;
    }
  }
  
  // Returns the cell value from the board with the given coordinates
  public int getBoardCell(int row, int col) {
    return board[row][col];
  }
  
  // Returns true if the cell value should be displayed on the screen
  public boolean isCellDisplayed(int row, int col) {
    return displaying[row][col];
  }
  
  public void changeFlagState (int row, int col) {
    if (flagged[row][col]) {
      flagged[row][col] = false;
    } else {
      flagged[row][col] = true;
    }
  }
  
  // Returns all cell values on the board
  public int[][] getBoard() {
    return board;
  }
  
  // Returns each cell's displaying value
  public boolean[][] getDisplaying() {
    return displaying;
  }
  
  public boolean[][] getFlagged() {
    return flagged;
  }
  
  public boolean isFlagged(int row, int col) {
    return flagged[row][col];
  }
}

// Stores all methods for communication with the user
class View {
  // The image of a mine taken from the internet
  private PImage mineImage;
  
  // The image of a flag taken from the internet
  private PImage flagImage;
  
  public View() {
    mineImage = loadImage("https://is1-ssl.mzstatic.com/image/thumb/Purple117/v4/ab/22/44/ab22447d-7b7b-26a3-fec8-a2f8399c6298/mzl.nnkcdmgj.png/246x0w.jpg");
    flagImage = loadImage("https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Minesweeper_flag.svg/2000px-Minesweeper_flag.svg.png");
    mineImage.resize(cellSize-5, cellSize-5); // cellSize - 5 allows the image to fit in the cell.
    flagImage.resize(cellSize-5, cellSize-5);
  }
  
  // Draws cell borders on the screen.
  public void drawCellBorders() { 
    for (int i=0; i<cellCount*cellSize; i+=cellSize) {
      line (0, i, 800, i);
      line (i, 0, i, 800);
    }
  }
  
  // Displays the selected cell values on the screen
  public void drawBoard(int[][] board, boolean[][] displaying, boolean[][] flagged) {
    for (int i=0; i<cellCount; i++) {
      for (int k=0; k<cellCount; k++) {
        if (flagged [i][k]) {
          displayFlag(i, k);
        } else if (displaying[i][k]) {
            int value = board[i][k];
            if (value > 0) {
              displayCellValue(i, k, value);
            } else if (value == 0) {
              displayEmptyCell(i, k);
            }
        }
      }
    }
  }
  
  // Displays all cell values on the screen
  public void drawBoard(int[][] board, boolean[][] flagged) {
    for (int i=0; i<cellCount; i++) {
      for (int k=0; k<cellCount; k++) {
          if (flagged [i][k]) {
          displayFlag(i, k);
          } else {
            int value = board[i][k];
            if (value > 0) {
              displayCellValue(i, k, value);
            } else if (value == 0) {
              displayEmptyCell(i, k);
            } else if (value == MINE) {
              displayMine(i, k);
          }
        }
      }
    }
  }
  
  // Chooses the colour for the cell value and displays it on the screen
  private void displayCellValue(int row, int col, int value) {
    chooseColour(value);
    // Writing the number at the correct position on the screen
    if (cellCount <= 8) {
      writeSmallerNumber(row, col, value);
    } else {
      writeBiggerNumber(row, col, value);
    }
  }
  
  // Sets the appropriate colour for the given cell value
  private void chooseColour(int value) {
    if (value == 1) fill(60, 60, 255); // blue
    if (value == 2) fill(10, 160, 10); // green
    if (value == 3) fill(200, 40, 10); // red
    if (value == 4) fill(128, 0, 128); // purple
    if (value == 5) fill(128, 0, 0); // maroon
    if (value == 6) fill(63, 224, 208); // turqoise
    if (value == 7) fill(0); // black
    if (value == 8) fill(100, 100, 100); // grey
  }
  
  // Writes a smaller number when the cell is smaller
  private void writeSmallerNumber(int row, int col, int value) {
    text(value, row * cellSize+cellSize / 2, col * cellSize + cellSize / 2);
  }
  
  // Write a bigger number when the cell is larger
  private void writeBiggerNumber(int row, int col, int value) {
    text(value, row * cellSize+cellSize / 2, col * cellSize+cellSize / 1.5);
  }
  
  // Makes empty cells (with value 0) look grey on the screen
  private void displayEmptyCell(int row, int col) {
    fill(200, 200, 200);
    rect(cellSize * row + cellSize / 28, cellSize * col + cellSize / 28, cellSize - 5, cellSize - 5);
  }
  
  // Displays the mine picture in the given cell
  private void displayMine(int row, int col) {
    image(mineImage, cellSize * row + cellSize / 28, cellSize * col + cellSize / 28);
  }
  
  public void displayFlag(int row, int col) {
    image(flagImage, cellSize * row + cellSize / 28, cellSize * col + cellSize / 28);
  }
  
  public void displayBottom(int startTime, int endTime) {
    drawBottomBackground();
    timePassed(startTime, endTime);
  }
  
  private void drawBottomBackground() {
    fill(30);
    rect(0, 800, width, height - 800); 
  }
  
  private void timePassed(int startTime, int endTime) {
    if (!hasLost) {
      writeTimeRunning(startTime);
    } else {
      writeEndTime(endTime);
    }
  }
  
  private void writeTimeRunning(int startTime) {
    if (startTime > 0 && startTime < 99999) {
        int time = (millis() - startTime) / 1000;
        writeTime(time);
      } else {
        writeTime(0);
      }
  }
  
  private void writeEndTime(int endTime) {
    int time = (endTime - startTime) / 1000;
    writeTime(time);
  }
  
  private void writeTime(int time) {
    fill(197, 232, 23);
    String timeText = String.format("Time passed: %s", time);
    text(timeText, 40, 850);
  }
}
