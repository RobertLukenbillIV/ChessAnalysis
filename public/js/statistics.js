// Statistics page functionality
class StatisticsManager {
    constructor() {
        this.setupEventListeners();
        this.loadStatistics();
    }

    setupEventListeners() {
        // Import button
        document.getElementById('import-btn').addEventListener('click', () => {
            document.getElementById('import-file').click();
        });

        // File input change
        document.getElementById('import-file').addEventListener('change', (e) => {
            this.handleFileImport(e);
        });

        // Export button
        document.getElementById('export-btn').addEventListener('click', () => {
            this.exportGames();
        });

        // Modal close
        document.querySelector('.close').addEventListener('click', () => {
            this.closeModal();
        });

        // Click outside modal to close
        window.addEventListener('click', (e) => {
            const modal = document.getElementById('replay-modal');
            if (e.target === modal) {
                this.closeModal();
            }
        });
    }

    loadStatistics() {
        this.loadOpenings();
        this.loadEndgamePositions();
    }

    loadOpenings() {
        fetch('/statistics/openings')
            .then(response => response.json())
            .then(data => {
                this.renderOpeningsTable(data);
            })
            .catch(error => {
                console.error('Error loading openings:', error);
            });
    }

    loadEndgamePositions() {
        fetch('/statistics/endgame_positions')
            .then(response => response.json())
            .then(data => {
                this.renderEndgameTable(data);
            })
            .catch(error => {
                console.error('Error loading endgame positions:', error);
            });
    }

    renderOpeningsTable(openings) {
        const tbody = document.getElementById('openings-tbody');
        tbody.innerHTML = '';

        openings.forEach(opening => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${opening.opening_name}</td>
                <td>
                    <a href="#" class="replay-link" data-type="opening" data-id="${opening.id}">
                        View Position
                    </a>
                </td>
                <td>${opening.use_count}</td>
                <td>${opening.success_rate}%</td>
            `;
            tbody.appendChild(row);
        });

        // Add event listeners to replay links
        document.querySelectorAll('.replay-link[data-type="opening"]').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                this.showReplay('opening', e.target.dataset.id);
            });
        });
    }

    renderEndgameTable(positions) {
        const tbody = document.getElementById('endgame-tbody');
        tbody.innerHTML = '';

        positions.forEach(position => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${position.position_name}</td>
                <td>
                    <a href="#" class="replay-link" data-type="endgame" data-id="${position.id}">
                        View Position
                    </a>
                </td>
                <td>${position.use_count}</td>
                <td>${position.success_rate}%</td>
            `;
            tbody.appendChild(row);
        });

        // Add event listeners to replay links
        document.querySelectorAll('.replay-link[data-type="endgame"]').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                this.showReplay('endgame', e.target.dataset.id);
            });
        });
    }

    showReplay(type, id) {
        fetch(`/replay/${type}/${id}`)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    alert('Error loading position: ' + data.error);
                    return;
                }

                // Show modal
                document.getElementById('replay-modal').style.display = 'block';
                
                // Create chess board for replay
                if (!this.replayBoard) {
                    this.replayBoard = new ChessBoard('replay-board');
                }

                if (data.type === 'opening' && data.moves) {
                    this.setupOpeningReplay(data.moves, data.fen);
                } else if (data.type === 'endgame' && data.fen) {
                    this.setupEndgameReplay(data.fen);
                }
            })
            .catch(error => {
                console.error('Error loading replay:', error);
                alert('Error loading position');
            });
    }

    setupOpeningReplay(moves, finalFen) {
        // For opening replay, we'd need to step through moves
        // This is a simplified version that just shows the final position
        this.replayBoard.updatePosition(finalFen || 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
        
        // Setup replay controls
        this.setupReplayControls(moves.split(' '));
    }

    setupEndgameReplay(fen) {
        this.replayBoard.updatePosition(fen);
        
        // For endgame, just show the position
        document.getElementById('replay-start').style.display = 'none';
        document.getElementById('replay-step').style.display = 'none';
    }

    setupReplayControls(moves) {
        this.replayMoves = moves;
        this.currentMoveIndex = 0;
        
        document.getElementById('replay-start').onclick = () => {
            this.currentMoveIndex = 0;
            this.replayBoard.updatePosition('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
        };
        
        document.getElementById('replay-step').onclick = () => {
            if (this.currentMoveIndex < this.replayMoves.length) {
                // In a full implementation, this would step through moves
                this.currentMoveIndex++;
            }
        };
        
        document.getElementById('replay-reset').onclick = () => {
            this.currentMoveIndex = 0;
            this.replayBoard.updatePosition('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1');
        };
    }

    closeModal() {
        document.getElementById('replay-modal').style.display = 'none';
    }

    handleFileImport(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (e) => {
            try {
                const data = e.target.result;
                
                // Validate JSON
                JSON.parse(data);
                
                // Send to server
                fetch('/import_games', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: new URLSearchParams({
                        data: data
                    })
                })
                .then(response => response.json())
                .then(result => {
                    if (result.success) {
                        alert(`Successfully imported ${result.imported_count} games!`);
                        this.loadStatistics(); // Reload tables
                    } else {
                        alert('Import failed: ' + result.error);
                    }
                })
                .catch(error => {
                    console.error('Import error:', error);
                    alert('Import failed: Network error');
                });
                
            } catch (error) {
                alert('Invalid JSON file');
            }
        };
        
        reader.readAsText(file);
    }

    exportGames() {
        fetch('/export_games')
            .then(response => response.json())
            .then(data => {
                // Create download link
                const blob = new Blob([JSON.stringify(data, null, 2)], {
                    type: 'application/json'
                });
                
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = `chess_analysis_export_${new Date().toISOString().split('T')[0]}.json`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                URL.revokeObjectURL(url);
            })
            .catch(error => {
                console.error('Export error:', error);
                alert('Export failed');
            });
    }
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    new StatisticsManager();
});