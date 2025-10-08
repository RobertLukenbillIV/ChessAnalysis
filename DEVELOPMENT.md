# Chess Analysis - TDD Development Guide

## Project Overview

This Ruby-based chess analysis application follows Test-Driven Development (TDD) principles with a feature-branch workflow. Each feature is developed in isolation, thoroughly tested, and merged only after passing all tests.

## Development Workflow

### 1. Feature Branch Strategy

```bash
# Create and switch to feature branch
git checkout -b feature/chess-engine-setup
git push -u origin feature/chess-engine-setup

# Development cycle
# 1. Write failing tests
# 2. Implement minimal code to pass
# 3. Refactor while keeping tests green
# 4. Commit frequently with descriptive messages

# When feature is complete
git push origin feature/chess-engine-setup
# Create Pull Request on GitHub
# Merge only after all tests pass and code review
```

### 2. Recommended Feature Development Order

1. **feature/chess-engine-setup**
   - Complete chess game logic
   - Move validation
   - Game state management
   - FEN notation handling

2. **feature/database-layer**
   - Database models and relationships
   - Game persistence
   - Statistics calculation
   - Data validation

3. **feature/web-interface**
   - Sinatra routes
   - HTML templates
   - Basic CSS styling
   - Session management

4. **feature/chess-board-ui**
   - Interactive chess board
   - Move animations
   - Game controls
   - Visual feedback

5. **feature/statistics-engine**
   - Opening analysis
   - Endgame position tracking
   - Success rate calculations
   - Data aggregation

6. **feature/import-export**
   - JSON data import/export
   - Data validation
   - Error handling
   - File processing

## TDD Implementation Pattern

### Red-Green-Refactor Cycle

```ruby
# 1. RED: Write failing test
RSpec.describe ChessGameEngine do
  describe "#make_move" do
    it "validates move legality" do
      engine = ChessGameEngine.new
      result = engine.make_move('e2', 'e5') # Invalid move
      expect(result[:success]).to be false
    end
  end
end

# 2. GREEN: Write minimal code to pass
def make_move(from, to)
  # Minimal implementation
  { success: false }
end

# 3. REFACTOR: Improve code while keeping tests green
def make_move(from, to)
  # Full implementation with proper validation
  begin
    @game.move(from, to)
    { success: true }
  rescue Chess::IllegalMoveError
    { success: false }
  end
end
```

## Branch Protection Rules (GitHub Settings)

Configure these settings for the main branch:

1. **Require pull request reviews before merging**
2. **Require status checks to pass before merging**
3. **Require branches to be up to date before merging**
4. **Include administrators** (apply rules to admins too)

## Testing Standards

### Test Coverage Requirements
- Minimum 90% code coverage
- All public methods must have tests
- Edge cases and error conditions covered

### Test Structure
```ruby
RSpec.describe ClassName do
  let(:subject) { ClassName.new }
  
  describe "#method_name" do
    context "when condition is true" do
      it "returns expected result" do
        expect(subject.method_name).to eq(expected_result)
      end
    end
    
    context "when condition is false" do
      it "raises appropriate error" do
        expect { subject.method_name }.to raise_error(ErrorClass)
      end
    end
  end
end
```

## Code Quality Standards

### RuboCop Configuration
- Follow Ruby style guide
- Maximum line length: 120 characters
- Use single quotes for strings
- Trailing commas in multi-line hashes/arrays

### Git Commit Messages
```
feat: Add chess move validation logic

- Implement move legality checking
- Add support for special moves (castling, en passant)
- Include comprehensive test suite
- Update documentation

Closes #123
```

## Continuous Integration

The GitHub Actions workflow automatically:
1. Runs all tests on Ruby 3.2.0
2. Checks code style with RuboCop
3. Performs security audit with bundler-audit
4. Reports test coverage
5. Blocks merge if any checks fail

## Local Development Commands

```bash
# Setup (run once)
./setup.sh

# Development server with auto-reload
bundle exec rerun ruby app.rb

# Run tests
bundle exec rspec

# Run tests with coverage
bundle exec rspec --format documentation

# Code style check
bundle exec rubocop

# Auto-fix style issues
bundle exec rubocop -a

# Security audit
bundle audit

# Database reset (if needed)
rm db/chess_analysis.db && ruby db/migrate.rb
```

## Feature Implementation Checklist

For each feature branch:

- [ ] Create feature branch from main
- [ ] Write failing tests for new functionality
- [ ] Implement minimal code to pass tests
- [ ] Refactor while keeping tests green
- [ ] Add integration tests
- [ ] Update documentation
- [ ] Run full test suite
- [ ] Check code style with RuboCop
- [ ] Security audit passes
- [ ] Manual testing in browser
- [ ] Create pull request
- [ ] Code review and approval
- [ ] Merge to main

## Database Schema Management

```ruby
# Add new migration
# Create new file: db/migrations/002_add_new_table.rb

# Run migrations
ruby db/migrate.rb

# Reset database (development only)
rm db/chess_analysis.db && ruby db/migrate.rb
```

## Debugging and Troubleshooting

### Common Issues
1. **Database locked**: Close all connections, restart server
2. **Test failures**: Check database state, clear test data
3. **Style violations**: Run `rubocop -a` for auto-fixes
4. **JavaScript errors**: Check browser console, verify API responses

### Debug Tools
```ruby
# Add to code for debugging
require 'pry'; binding.pry

# In tests, use detailed output
bundle exec rspec --format documentation --backtrace
```

## Performance Considerations

1. **Database queries**: Use indexes for frequently queried columns
2. **Chess calculations**: Cache expensive computations
3. **Frontend**: Minimize API calls, use efficient DOM updates
4. **Memory usage**: Clean up chess engine instances after games

This development approach ensures high code quality, comprehensive testing, and maintainable code architecture while following TDD principles throughout the development process.