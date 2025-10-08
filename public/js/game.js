// Main game logic for the chess interface
class ChessGame {
    constructor() {
        this.board = new ChessBoard('chessboard');
        this.gameOver = false;
        this.currentPlayer = 'white';
        this.setupEventListeners();
        this.updateGameStatus('Game in progress', 'White to move');
    }

    setupEventListeners() {
        // Resign button
        document.getElementById('resign-btn').addEventListener('click', () => {
            this.resignGame();
        });

        // New game button
        document.getElementById('new-game-btn').addEventListener('click', () => {
            window.location.href = '/game';
        });

        // Return to menu button
        document.getElementById('return-menu-btn').addEventListener('click', () => {
            window.location.href = '/';
        });
    }

    makeMove(from, to, promotion = null) {
        if (this.gameOver) return;

        // Show loading state
        this.updateGameStatus('Processing move...', '');

        // Send move to server
        fetch('/move', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                from: from,
                to: to,
                promotion: promotion
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Update board with new position
                this.board.updatePosition(data.game_state.fen);
                
                // Update game status
                if (data.game_state.game_over) {
                    this.handleGameEnd(data.game_state);
                } else {
                    // Switch current player
                    this.currentPlayer = this.currentPlayer === 'white' ? 'black' : 'white';
                    this.updateGameStatus('Game in progress', `${this.currentPlayer.charAt(0).toUpperCase() + this.currentPlayer.slice(1)} to move`);
                }
            } else {
                // Show error
                this.updateGameStatus('Invalid move', `${this.currentPlayer.charAt(0).toUpperCase() + this.currentPlayer.slice(1)} to move`);
                console.error('Move error:', data.error);
            }
        })
        .catch(error => {
            console.error('Network error:', error);
            this.updateGameStatus('Network error', 'Please try again');
        });
    }

    handleGameEnd(gameState) {
        this.gameOver = true;
        
        let result;
        let statusMessage;
        
        if (gameState.checkmate) {
            const winner = gameState.winner;
            result = winner === 'white' ? 'white_wins' : 'black_wins';
            statusMessage = `Checkmate! ${winner.charAt(0).toUpperCase() + winner.slice(1)} wins!`;
        } else {
            // For now, assume any other game end is a draw
            result = 'draw';
            statusMessage = 'Game ended in a draw';
        }
        
        this.updateGameStatus('Game Over', statusMessage);
        this.showGameEndButtons();
        
        // Send game result to server
        this.finishGame(result);
    }

    resignGame() {
        if (this.gameOver) return;
        
        const winner = this.currentPlayer === 'white' ? 'black' : 'white';
        const result = winner === 'white' ? 'white_wins' : 'black_wins';
        
        this.gameOver = true;
        this.updateGameStatus('Game Over', `${this.currentPlayer.charAt(0).toUpperCase() + this.currentPlayer.slice(1)} resigned. ${winner.charAt(0).toUpperCase() + winner.slice(1)} wins!`);
        this.showGameEndButtons();
        
        this.finishGame(result);
    }

    finishGame(result) {
        // Send final game state to server
        fetch('/game/finish', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                result: result
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                console.log('Game saved with ID:', data.game_id);
            } else {
                console.error('Error saving game:', data.error);
            }
        })
        .catch(error => {
            console.error('Network error saving game:', error);
        });
    }

    updateGameStatus(status, playerInfo) {
        document.getElementById('game-status').textContent = status;
        document.getElementById('current-player').textContent = playerInfo;
    }

    showGameEndButtons() {
        document.getElementById('resign-btn').style.display = 'none';
        document.getElementById('new-game-btn').style.display = 'block';
        document.getElementById('return-menu-btn').style.display = 'block';
    }
}

// Initialize game when page loads
document.addEventListener('DOMContentLoaded', function() {
    window.ChessGame = new ChessGame();
});