// Simple chessboard implementation
class ChessBoard {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        this.selectedSquare = null;
        this.currentFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
        this.initBoard();
        this.renderPosition();
    }

    initBoard() {
        this.container.innerHTML = '';
        this.container.className = 'chessboard';
        
        for (let rank = 8; rank >= 1; rank--) {
            for (let file = 1; file <= 8; file++) {
                const square = document.createElement('div');
                const fileChar = String.fromCharCode(96 + file); // a-h
                const squareName = fileChar + rank;
                
                square.className = 'square ' + ((rank + file) % 2 === 0 ? 'dark' : 'light');
                square.id = squareName;
                square.addEventListener('click', (e) => this.handleSquareClick(e));
                
                // Add coordinate labels
                if (file === 1) {
                    const rankLabel = document.createElement('span');
                    rankLabel.className = 'rank-label';
                    rankLabel.textContent = rank;
                    square.appendChild(rankLabel);
                }
                
                if (rank === 1) {
                    const fileLabel = document.createElement('span');
                    fileLabel.className = 'file-label';
                    fileLabel.textContent = fileChar;
                    square.appendChild(fileLabel);
                }
                
                this.container.appendChild(square);
            }
        }
    }

    renderPosition() {
        // Clear all pieces
        document.querySelectorAll('.piece').forEach(piece => piece.remove());
        
        const [board] = this.currentFen.split(' ');
        const ranks = board.split('/');
        
        for (let rankIndex = 0; rankIndex < 8; rankIndex++) {
            const rank = ranks[rankIndex];
            let fileIndex = 0;
            
            for (let char of rank) {
                if (isNaN(char)) {
                    // It's a piece
                    const file = String.fromCharCode(97 + fileIndex); // a-h
                    const rankNum = 8 - rankIndex;
                    const squareId = file + rankNum;
                    const square = document.getElementById(squareId);
                    
                    if (square) {
                        const piece = document.createElement('div');
                        piece.className = 'piece ' + (char === char.toUpperCase() ? 'white' : 'black') + ' ' + this.getPieceName(char);
                        square.appendChild(piece);
                    }
                    
                    fileIndex++;
                } else {
                    // It's a number of empty squares
                    fileIndex += parseInt(char);
                }
            }
        }
    }

    getPieceName(char) {
        const pieces = {
            'k': 'king', 'q': 'queen', 'r': 'rook',
            'b': 'bishop', 'n': 'knight', 'p': 'pawn'
        };
        return pieces[char.toLowerCase()] || 'unknown';
    }

    handleSquareClick(event) {
        const square = event.currentTarget;
        const squareId = square.id;
        
        // Clear previous highlights
        document.querySelectorAll('.square').forEach(s => {
            s.classList.remove('selected', 'possible-move', 'highlighted');
        });
        
        if (this.selectedSquare === squareId) {
            // Deselect if clicking the same square
            this.selectedSquare = null;
            return;
        }
        
        if (this.selectedSquare) {
            // Attempt to make a move
            this.makeMove(this.selectedSquare, squareId);
            this.selectedSquare = null;
        } else {
            // Select the square if it has a piece
            if (square.querySelector('.piece')) {
                this.selectedSquare = squareId;
                square.classList.add('selected');
                // In a full implementation, show possible moves here
            }
        }
    }

    makeMove(from, to) {
        // This would send the move to the server
        console.log(`Move attempted: ${from} to ${to}`);
        
        // In the actual implementation, this would make an AJAX call
        // For now, just log the move
        if (window.ChessGame) {
            window.ChessGame.makeMove(from, to);
        }
    }

    updatePosition(fen) {
        this.currentFen = fen;
        this.renderPosition();
    }

    highlightSquare(squareId, className = 'highlighted') {
        const square = document.getElementById(squareId);
        if (square) {
            square.classList.add(className);
        }
    }

    clearHighlights() {
        document.querySelectorAll('.square').forEach(square => {
            square.classList.remove('selected', 'possible-move', 'highlighted', 'check');
        });
    }
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ChessBoard;
} else {
    window.ChessBoard = ChessBoard;
}