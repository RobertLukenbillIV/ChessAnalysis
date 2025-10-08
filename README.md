# ChessAnalysis
This project specifically focuses on Chess analysis, providing players with information on various positions, their rate of appearance and their likelihood of success from past games.

## Requirements
- Functionally animated basic Chess site application that is locally hosted with a local database setup.
- Play is made by the same user for limits of the project requirements on both sides of the board.
- Upon completion of a game, the application stores the following statistics:
  - The first ten moves for both sides (named the "Opening" for White and Black).
  - The position of all pieces for both sides at the end of the game (named the "Ending" for White and Black).
- In the Main Menu, the user can start a game or view statistics.
- The site will have one main page "The Main Menu" that points to various other pages, specifically: "Start Game", "Statistics".
  - "Start Game" will start a normal chess game on its page and upon completion it will inform the player of the game finishing when one side has won. The player has the choice of buttons appearing to "Resign" while the game is playing, "Return to Main Menu" when the game is completed, "Start a new Game" when the game is finished.
  - "Statistics" will pull up a visual database where the player can select one of the category Tables and pull up all entries in those tables. The two categories are "Openings" and "Endgame Positions".
- The Opening Table will containing the following columns: "Opening Name", "Position", "Use Rate", "Success Rate".
  - "Opening Name" will be just the name of the chess notation of the first position taken by White.
  - "Position" will be the chess notation of all 10 moves that White and Black move in their turns. The user will simply see a clickable link to take them to a chess board and show them an animated view of the moves being made on the board.
  - "Use Rate" is a integer value of the number of times that Opening position has been made.
  - "Success Rate" is a decimal value of the success rate containing the liklihood of White winning on the position.
- Similarly, the Endgame Positions will containing similar columns: "Endgame Position Name", "Position", "Use Rate", "Success Rate".
