package views
{
	import flash.events.Event;
	
	import hoxserver.*;
	
	import mx.collections.ArrayCollection;
	import mx.containers.ControlBar;
	import mx.containers.HBox;
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.UIComponent;

	public class TableListView  extends Panel
	{
		public function TableListView(parent:UIComponent)
		{
			this.title = "Current Tables";
			this.id = "viewTablesPanel";
			parent.addChild(this);
		}

		public function display(tableList:Object) : void {
			this.horizontalScrollPolicy = "on";
			this.verticalScrollPolicy = "on";

			var grid:DataGrid = new DataGrid();
			var t:TableInfo = new TableInfo();

			// add Table header column names
			var colNames:Array = [
			"tid",
			"group",
			"gametype",
			"initialtime",
			//"redtime",
			//"blacktime",
			"redid",
			"redscore",
			"blackid",
			"blackscore"];
			var columnName:DataGridColumn;
            var cols:Array = null;
			for (var j:String in colNames) {
				trace(colNames[j]);
				columnName = new DataGridColumn(colNames[j]);
				if (colNames[j] == "tid") {
                    columnName.sortCompareFunction = sortTid;
				} else if (colNames[j] == "redscore") {
                    columnName.sortCompareFunction = sortRedScore;
                } else if (colNames[j] == "blackscore") {
                    columnName.sortCompareFunction = sortBlackScore;
                }
                cols = grid.columns;
                cols.push(columnName);
                grid.columns = cols;
			}
			// add table data
			var dp:ArrayCollection = new ArrayCollection();
			var tableInfo:Object = {}
			var tableData:TableInfo = null;
			var value:String = "";
			var nValue:int = 0;
			if (tableList.length > 0) {
				for (var i:int = 0; i < tableList.length; i++) {
					tableData = tableList[i];
					if (tableData) {
						tableInfo = {};
						for(j in colNames)
						{
							value = tableList[i][colNames[j]];
							if (colNames[j] == "tid" || colNames[j] == "redscore" || colNames[j] == "blackscore") {
								nValue = parseInt(value);
								tableInfo[colNames[j]] = nValue;
							} else {
								if (colNames[j] == "group") {
									if (value == "0") {
										value = "public";
									} else {
										value = "private";
									}
								} else if (colNames[j] == "gametype") {
									if (value == "0") {
										value = "Rated";
									} else {
										value = "Unrated";
									}
								}
								tableInfo[colNames[j]] = value;
							}
						}
						dp.addItem(tableInfo);
					}
				}
				grid.dataProvider = dp;
				grid.rowCount = dp.length;
				trace("table list length: " + grid.rowCount );
				grid.addEventListener("change", function(event:Event) : void {
					var obj:DataGrid = DataGrid(event.target);
					trace("selected tid: " +  obj.selectedItem.tid);
				});
			}
			else {
				for(j in colNames)
				{
					tableInfo[colNames[j]] = "";
				}
				dp.addItem(tableInfo);
				grid.rowCount = 1;
				grid.dataProvider = dp;
			}
			this.addChild(grid);

			var controlBar:ControlBar = new ControlBar();
			this.addChild(controlBar);
			var hBox:HBox = new HBox();
			controlBar.addChild(hBox);
			if (tableList.length > 0) {
				var joinTableBtn:Button = new Button();
				hBox.addChild(joinTableBtn);
				joinTableBtn.label = LocaleMgr.instance().getResourceId("ID_JOINTABLE");
				joinTableBtn.addEventListener("click", function(event:Event) : void {
					if (grid.selectedItem) {
						trace("selected tid: " + grid.selectedItem.tid);
						Global.vars.app.doJoinTable(grid.selectedItem.tid);
					}
				});
			}
			var refreshBtn:Button = new Button();
			refreshBtn.label = LocaleMgr.instance().getResourceId("ID_REFRESH");
			hBox.addChild(refreshBtn);
			refreshBtn.addEventListener("click", function(event:Event) : void {
				Global.vars.app.doViewTables();
				});
			Global.vars.app.menu.showNavMenu();
		}
        public function sortTid(obj1:Object, obj2:Object) : int {
            return Util.sortNumeric(obj1, obj2, "tid");
        }
        public function sortRedScore(obj1:Object, obj2:Object) : int {
            return Util.sortNumeric(obj1, obj2, "redscore");
        }
        public function sortBlackScore(obj1:Object, obj2:Object) : int {
            return Util.sortNumeric(obj1, obj2, "blackscore");
        }
	}
}