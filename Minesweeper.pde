// My first programming project.
// First fully working version was done in 2018, added comments and refactored a bit in 2021.

// Number of cells in a row/column. Can be changed
int cellCount = 10;

// Size of one cell in pixels.
final int cellSize = 800/cellCount;

// The number of mines on the board. can be changed
int mineCount = 10;

// Shows if the player has pressed on the mine and lost the game.
boolean hasLost = false;

// Shows if the player has won the game
boolean hasWon = false;

// Used for saving the amount of time which has passed between opening the game and starting it.
int startTime;

// Used for saving the time when the game ends.
int endTime;

// Mine marker on the board.
public final int MINE = -1;

private Model model;
private View view;

// The starting values are initialised in setup.
public void setup() {
  // The size of the game window is 800x800 pixels.
  size(800, 900);
  background(200);
  model = new Model(mineCount);
  view = new View();
  startTime = -1;
  endTime = -1;
}

// This is the main game cycle. 
// It constantly repeats and updates the game screen.
public void draw() {
  view.drawCellBorders();
  if (!hasLost) {
    // only some cells are displayed.
    view.drawBoard(model.getBoard(), model.getDisplaying(), model.getFlagged());
  } else {
    // full board is displayed.
    view.drawBoard(model.getBoard(), model.getFlagged());
  }
  view.displayBottom(startTime, endTime, model.getMinesLeft());
}

// Controls the data flow for each mouse button pressed.
public void mousePressed() {
  // Makes sure that user pressed on a cell.
  if (isMouseOnCell()) {
    
    int mouseRow = mouseX/cellSize;
    int mouseCol = mouseY/cellSize;
    
    if (startTime == -1) {
      startTime = millis();
    }
    
    if (mouseButton == LEFT) {
      LeftPressed(mouseRow, mouseCol);
    }
    if (mouseButton == RIGHT && !hasWon && !hasLost) {
      RightPressed(mouseRow, mouseCol);
    }
  }
  else if (isMouseOnRestart()) {
    model.resetState();
  }
}

// Validation method for ensuring that mouse in on a cell.
private boolean isMouseOnCell() {
  return (mouseX < 800 && mouseY < 800);
}

// Validation method for ensuring that the mouse is on the restart button (face on the bottom).
private boolean isMouseOnRestart() {
  return (mouseX > 340 && mouseY > 830 && mouseX < 400 && mouseY < 890);
}

// Opens user's selected cell if possible.
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

// Adds a flag if possible.
private void RightPressed(int row, int col) {
  if (!model.isCellDisplayed(row, col) && !hasLost && !hasWon) {
    model.changeFlagState(row, col);
  }
  else if (model.isFlagged(row, col)) {
    model.changeFlagState(row, col);
  }
  checkWin();
}

// Checks if the game has been won.
private void checkWin() {
  if (model.getRealMinesLeft() == 0 && model.getMinesLeft() == 0) {
    hasWon = true;
    endTime = millis();
  }
}

// Contains all game logic.
class Model {
  
  // saves board data including the mine counts around the cell
  // and also the mine positions
  private int[][] board;
  
  // mine markers on the board
  private final int MINE = -1;
  
  // used for saving cells which are being displayed
  private boolean[][] displaying;
  
  // the number of mines on the game board
  private int mineCount;
  
  // used for saving visited cells when opening large empty areas with recursion
  private boolean[][] visited;
  
  // used for saving flagged cells
  private boolean[][] flagged;
  
  // Shows if the player has pressed on the mine and lost the game.
  private boolean hasLost = false;

  // Shows if the player has won the game
  private boolean hasWon = false;
  
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
    //if (!inRange(row, col)) return;
    if (flagged[row][col]) {
      changeFlagState(row, col);
    }
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
    for (int i = 0; i < mineCount; i++) {
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
  
  // Switches the cell from flagged to unflagged and vice-versa.
  public void changeFlagState(int row, int col) {
    if (flagged[row][col]) {
      flagged[row][col] = false;
    } else {
      flagged[row][col] = true;
    }
  }
  
  // Calculates the difference between mine count and flagged cells.
  public int getMinesLeft() {
    int minesLeft = mineCount;
    for (int i = 0; i < cellCount; i++) {
      for (int j = 0; j < cellCount; j++) {
        if (flagged[i][j]) {
          minesLeft--;
        }
      }
    }
    return minesLeft;
  }
  
  // Calculates how many mines are unflagged.
  public int getRealMinesLeft() {
    int realMinesLeft = mineCount;
    for (int i = 0; i < cellCount; i++) {
      for (int j = 0; j < cellCount; j++) {
        if (board[i][j] == MINE && flagged[i][j]) {
          realMinesLeft --;
        }
      }
    }
    return realMinesLeft;
  }
  
  // Starts a new game by resetting the game state.
  public void resetState() {
    background(200);
    board = new int[cellCount][cellCount];
    displaying = new boolean[cellCount][cellCount];
    visited = new boolean[cellCount][cellCount];
    flagged = new boolean[cellCount][cellCount];
    hasWon = false;
    hasLost = false;
    generateMines();
    startTime = -1;
    endTime = -1;
    findCellNumbers(cellCount);
  }
  
  // Returns all cell values on the board
  public int[][] getBoard() {
    return board;
  }
  
  // Returns each cell's displaying value
  public boolean[][] getDisplaying() {
    return displaying;
  }
  
  // Returns each cell's flagged states.
  public boolean[][] getFlagged() {
    return flagged;
  }
  
  // Returns true if the given cell is flagged.
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
  
  // The winning face image drawn by myself :)
  private PImage winFace;
  
  // The smiley face image drawn by myself :)
  private PImage smileyFace;
  
  // The losing face image drawn by myself :)
  private PImage loseFace;
  
  public View() {
    mineImage = loadImage("mineImage.png");
    flagImage = loadImage("flagImage.png");

    winFace = loadImage("win.png");
    smileyFace = loadImage("smile.png");
    loseFace = loadImage("lose.png");
    // cellSize - 5 allows the image to fit in the cell.
    mineImage.resize(cellSize-5, cellSize-5); 
    flagImage.resize(cellSize-5, cellSize-5);
    winFace.resize(60, 60);
    smileyFace.resize(60, 60);
    loseFace.resize(60, 60);
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
        } else {
          displayCell(i, k, displaying[i][k], board[i][k]);
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
          displayCell(i, k, board[i][k]);
        }
      }
    }
  }
  
  // Displays a cell value on the screen if it is displayed. Does not display mines.
  private void displayCell(int row, int col, boolean isDisplayed, int value) {
    if (isDisplayed) {
      if (value > 0) {
        displayCellValue(row, col, value);
      } else if (value == 0) {
        displayEmptyCell(row, col);
      }
    } else {
      displayUndiscoveredCell(row, col);
    }
  }
  
  // Displays every cell on the screen, no matter if it is displayed or not (even mines).
  private void displayCell(int row, int col, int value) {
    if (value > 0) {
      displayCellValue(row, col, value);
    } else if (value == 0) {
      displayEmptyCell(row, col);
    } else if (value == MINE) {
      displayMine(row, col);
    }
  }
  
  // Chooses the colour for the cell value and displays it on the screen.
  private void displayCellValue(int row, int col, int value) {
    displayEmptyCell(row, col);
    chooseColour(value);
    // Writing the number at the correct position on the screen
    if (cellCount <= 8) {
      writeSmallerNumber(row, col, value);
    } else {
      writeBiggerNumber(row, col, value);
    }
  }
  
  // Draws the given cell in grey colour (representing undiscovered cell).
  private void displayUndiscoveredCell(int row, int col) {
    fill(200);
    rect(cellSize * row, cellSize * col, cellSize, cellSize);
  }
  
  // Sets the appropriate colour for the given cell value.
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
  
  // Writes a smaller number when the cell size is smaller.
  private void writeSmallerNumber(int row, int col, int value) {
    textSize(45);
    text(value, row * cellSize+cellSize / 2 - 12, col * cellSize + cellSize / 2);
  }
  
  // Write a bigger number when the cell size is larger.
  private void writeBiggerNumber(int row, int col, int value) {
    textSize(45);
    text(value, row * cellSize+cellSize / 2 - 12, col * cellSize+cellSize / 1.5);
  }
  
  // Makes empty cells (with value 0) look white on the screen.
  private void displayEmptyCell(int row, int col) {
    fill(255);
    rect(cellSize * row, cellSize * col, cellSize, cellSize);
  }
  
  // Displays the mine picture in the given cell.
  private void displayMine(int row, int col) {
    image(mineImage, cellSize * row + cellSize / 28, cellSize * col + cellSize / 28);
  }
  
  // Displays the flag picture in the given cell.
  public void displayFlag(int row, int col) {
    image(flagImage, cellSize * row + cellSize / 28, cellSize * col + cellSize / 28);
  }
  
  // Displays the bottom panel of the game.
  public void displayBottom(int startTime, int endTime, int minesLeft) {
    drawBottomBackground();
    timePassed(startTime, endTime);
    writeMinesLeft(minesLeft);
    displayFace();
  }
  
  // Fills the background of the bottom panel.
  private void drawBottomBackground() {
    fill(30);
    rect(0, 800, width, height - 800);
  }
  
  // Shows running time if the game is in progress, otherwise shows game end time.
  private void timePassed(int startTime, int endTime) {
    if (!hasLost && !hasWon) {
      writeTimeRunning(startTime);
    } else {
      writeEndTime(endTime);
    }
  }
  
  // Displays how much time has passed since the game started.
  // The game starts with the first click.
  // The time difference between opening the game and first click is recorded in startTime.
  private void writeTimeRunning(int startTime) {
    if (startTime > 0 && startTime < 99999) {
        int time = (millis() - startTime) / 1000;
        displayTime(time);
      } else {
        displayTime(0);
      }
  }
  
  // Writes how much time had passed from the first click when the game ended.
  private void writeEndTime(int endTime) {
    int time = (endTime - startTime) / 1000;
    displayTime(time);
  }
  
  // Displays the given time in seconds on the screen.
  private void displayTime(int time) {
    textSize(45);
    fill(197, 232, 23);
    String timeText = String.format("Time: %s", time);
    text(timeText, 40, 860);
  }
  
  // Displays the difference between mine count and unflagged cells on the screen.
  private void writeMinesLeft(int minesLeft) {
    String minesText = String.format("Mines: %s", minesLeft);
    text(minesText, 480, 860);
  }
  
  // Displays the game state in a picture on the bottom panel.
  private void displayFace() {
    if (hasWon) {
      image(winFace, 340, 830);
    } else if (hasLost) {
      image(loseFace, 340, 830);
    } else {
      image(smileyFace, 340, 830);
    }
  }
}
