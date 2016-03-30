package gomoku;

import java.awt.*;
import javax.swing.*;

public class GUI extends JFrame {
	private JButton[][] cells;
	private final int field_size,
					  cell_size;
	//private static final String columns = "abcdefghijklmnopqrstuvwzyx";
	
	public GUI(int fs, int cs) {
		super("Gomoku");
		field_size = fs + 1;
		cell_size = cs;
		cells = new JButton[field_size + 1][field_size + 1];
		JPanel field = new JPanel();
		field.setLayout(new GridLayout(field_size + 1,field_size + 1));
		cells[0][0] = new JButton("\\");
		field.add(cells[0][0]);
		for (int i = 1; i < field_size; i++) {
			cells[0][i] = new JButton("" + i);
			cells[0][i].setMargin(new Insets(1,1,1,1));
			field.add(cells[0][i]);
		}
		for (int i = 1; i < field_size; i++) {
			cells[i][0] = new JButton("" + i);
			cells[i][0].setMargin(new Insets(1,1,1,1));
			field.add(cells[i][0]);
			for (int j = 1; j < field_size; j++) {
				cells[i][j] = new JButton();
				cells[i][j].setMinimumSize(new Dimension(cell_size,cell_size));
				cells[i][j].setMargin(new Insets(1,1,1,1));
				field.add(cells[i][j]);
			}
		}
		setContentPane(field);
		setSize(cell_size * field_size, cell_size * field_size);
		setResizable(false);
		setVisible(true);
	}
	
	public void changeCellState(int x, int y, String text) throws Exception {
		if (x > field_size || y > field_size) {
			throw new Exception();	
		}
		cells[x][y].setText(text);
	}
		
}