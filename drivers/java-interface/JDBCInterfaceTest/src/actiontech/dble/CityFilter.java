package actiontech.dble;

import java.sql.SQLException;

import javax.sql.RowSet;
import javax.sql.rowset.Predicate;

public class CityFilter implements Predicate {

  private String[] cities;
  private String colName = null;
  private int colNumber = -1;

  public CityFilter(String[] citiesArg, String colNameArg) {
    this.cities = citiesArg;
    this.colNumber = -1;
    this.colName = colNameArg;
  }

  public CityFilter(String[] citiesArg, int colNumberArg) {
    this.cities = citiesArg;
    this.colNumber = colNumberArg;
    this.colName = null;
  }

  public boolean evaluate(Object valueArg, String colNameArg) {

    if (colNameArg.equalsIgnoreCase(this.colName)) {
      for (int i = 0; i < this.cities.length; i++) {
        if (this.cities[i].equalsIgnoreCase((String)valueArg)) {
          return true;
        }
      }
    }
    return false;
  }

  public boolean evaluate(Object valueArg, int colNumberArg) {

    if (colNumberArg == this.colNumber) {
      for (int i = 0; i < this.cities.length; i++) {
        if (this.cities[i].equalsIgnoreCase((String)valueArg)) {
          return true;
        }
      }
    }
    return false;
  }


  public boolean evaluate(RowSet rs) {

    if (rs == null)
      return false;

    try {
      for (int i = 0; i < this.cities.length; i++) {

        String cityName = null;

        if (this.colNumber > 0) {
          cityName = (String)rs.getObject(this.colNumber);
        } else if (this.colName != null) {
          cityName = (String)rs.getObject(this.colName);
        } else {
          return false;
        }

        if (cityName.equalsIgnoreCase(cities[i])) {
          return true;
        }
      }
    } catch (SQLException e) {
      return false;
    }
    return false;
  }

}
