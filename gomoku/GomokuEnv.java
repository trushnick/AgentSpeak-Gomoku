// Environment code for project course_paper.mas2j
package gomoku;

import jason.asSyntax.*;
import jason.environment.*;
import java.util.logging.*;

public class GomokuEnv extends Environment {

	private static final int field_size = 15;
	private static final int cell_size = 45;
	
	private GomokuRoutines routines = new GomokuRoutines(field_size);
	private GUI gui = new GUI(field_size, cell_size);
    private Logger logger = Logger.getLogger("course_paper.mas2j." + BoardGUI.class.getName());

    /** Called before the MAS execution with the args informed in .mas2j */
    @Override
    public void init(String[] args) {
        super.init(args);
    }

    @Override
    public boolean executeAction(String agName, Structure action) {
		if (action.getFunctor().equals("move")) {
			try {
				int x = Integer.parseInt(action.getTerm(0).toString());
				int y = Integer.parseInt(action.getTerm(1).toString());
				if (agName.equals("player1")) {		
					gui.changeCellState(x, y, "X");
					routines.changeState(x - 1, y - 1, GomokuRoutines.Player.FIRST);
				} else {
					gui.changeCellState(x, y, "O");
					routines.changeState(x - 1, y - 1, GomokuRoutines.Player.SECOND);	
				}
			} catch (Exception e) {
				logger.info(e.getMessage());
			}
		} else {
			logger.info("executing: "+action+", but not implemented!");
			return false;
		}
        return true;
    }

    /** Called before the end of MAS execution */
    @Override
    public void stop() {
        super.stop();
    }
	
}

