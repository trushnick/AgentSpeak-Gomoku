package gomoku;

import java.util.Random;

public class GomokuRoutines {

	static enum Player {
		NONE, FIRST, SECOND	
	}
	
	private Player[][] field_state;
	private final int field_size;
	private Random random = new Random();
	
	public GomokuRoutines(int size) {
		field_size = size;
		field_state = new Player[field_size][field_size];
		for (int i = 0; i < field_size; i++) {
			for (int j = 0; j < field_size; j++) {
				field_state[i][j] = Player.NONE;
			}
		}
	}
	
	public boolean changeState(int x, int y, Player state) {
		if (x < 0 || x > field_size || y < 0 || y > field_size) {
			return false;
		} else {
			field_state[x][y] = state;
			return true;
		}
	}
	
	public boolean isWinningMove(Cell cell, Player player) {
		return horWin(cell, player) || vertWin(cell, player) || diagWin(cell, player);
	}
	
	private boolean horWin(Cell cell, Player player) {
		int sequence = 1;
		int	x = cell.getX() - 1;
		int	y = cell.getY();
		while (x > 0 && field_state[x][y] == player) {
			sequence++;
			x--;
		}
		x = cell.getX() + 1;
		while (x < field_size && field_state[x][y] == player) {
			sequence++;
			x++;
		}
		return sequence >= 5;
	}
	
	private boolean vertWin(Cell cell, Player player) {
		int sequence = 1;
		int x = cell.getX();
		int y = cell.getY() - 1;
		while (y > 0 && field_state[x][y] == player) {
			sequence++;
			y--;
		}
		y = cell.getY() + 1;
		while (y < field_size && field_state[x][y] == player) {
			sequence++;
			y++;
		}
		return sequence >= 5;
	}
	
	private boolean diagWin(Cell cell, Player player) {
		int sequence = 1;
		int x = cell.getX() - 1;
		int y = cell.getY() - 1;
		while (x > 0 && y > 0 && field_state[x][y] == player) {
			sequence++;
			x--;
			y--;
		}
		x = cell.getX() + 1;
		y = cell.getY() + 1;
		while (x < field_size && y < field_size && field_state[x][y] == player) {
			sequence++;
			x--;
			y--;
		}
		return sequence >= 5;
	}
	
	public Cell makeDecision(Player player) {
		if (allCellsBusy()) {
			return new Cell(0, 0);	
		}
		return random.nextDouble() < 0.5 ? makeRandomDecision() : makeSmartDecision(player);
	}
	
	private Cell makeRandomDecision() {
		int x = random.nextInt(field_size),
			y = random.nextInt(field_size);
		while (field_state[x][y] != Player.NONE) {
			x = random.nextInt(field_size);
			y = random.nextInt(field_size);
		}
		return new Cell(x, y);
	}
	
	private Cell makeSmartDecision(Player player) {
		System.out.println("Smart decision not implemented, making random one");
		return makeRandomDecision();
	}

	private boolean allCellsBusy() {
		for (int i = 0; i < field_size; i++) {
			for (int j = 0; j < field_size; j++) {
				if (field_state[i][j] == Player.NONE) {
					return false;
				}
			}
		}
		return true;
	}

}
