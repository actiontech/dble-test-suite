package actiontech.dble;

import javax.sql.RowSetEvent;
import javax.sql.RowSetListener;

public class ExampleRowSetListener implements RowSetListener {

	public void rowSetChanged(RowSetEvent event) {
		Main.print_debug("Called rowSetChanged in ExampleRowSetListener");
	}

	public void rowChanged(RowSetEvent event) {
		Main.print_debug("Called rowChanged in ExampleRowSetListener");
	}

	public void cursorMoved(RowSetEvent event) {
		Main.print_debug("Called cursorMoved in ExampleRowSetListener");
	}
}
