jQuery.fn.extend({
	Sheet: function() {
		var jSheet;
        (function(safeEval) {
            // Using a closure to keep global namespace clean.
            var theNumber = Number;
            var theParseInt = parseInt;
            var theParseFloat = parseFloat;
            var theIsNaN = isNaN;

            if (jSheet == null)
            jSheet = new Object();
            if (jSheet.TEST == null)
            jSheet.TEST = new Object();
            // For exposing to testing only.
			//////////////////////////////////////////////////////////////////////////////
            // The spreadsheetEngine should be DOM/DHTML independent, handling only
            // formula recalculations only, not UI.
            //
            var eng = jSheet.spreadsheetEngine = {
                ERROR: new String("#VALUE!"),
                standardFunctions: {
                    AVERAGE: function(values) {
                        return eng.standardFunctions.SUM(values) / eng.standardFunctions.COUNT(values);
                    },
                    COUNT: function(values) {
                        return fold(values, COUNT2, 0);
                    },
                    SUM: function(values) {
                        return fold(values, SUM2, 0);
                    },
                    MAX: function(values) {
                        return fold(values, MAX2, theNumber.MIN_VALUE);
                    },
                    MIN: function(values) {
                        return fold(values, MIN2, theNumber.MAX_VALUE);
                    }
                },
                calc: function(cellProvider, context, startFuel) {
                    // Returns null if all done with a complete calc() run.
                    // Else, returns a non-null continuation function if we ran out of fuel.  
                    // The continuation function can then be later invoked with more fuel value.
                    // The fuelStart is either null (which forces a complete calc() to the finish) 
                    // or is an integer > 0 to slice up long calc() runs.  A fuelStart number
                    // is roughly matches the number of cells to visit per calc() run.
                    var calcState = {
                        cellProvider: cellProvider,
                        context: (context != null ? context: {}),
                        row: 1,
                        col: 1,
                        done: false,
                        stack: [],
                        calcMore: function(moreFuel) {
                            calcState.fuel = moreFuel;
                            return calcLoop(calcState);
                        }
                    };
                    return calcState.calcMore(startFuel);
                },
                rewriteMovedFormulas: function(cells, atRow, atCol, deltaRows, deltaCols) {
                    // TODO.
                    },
                Cell: function() {}
                // Prototype setup is later.
            }

            var calcLoop = function(calcState) {
                with(calcState) {
                    if (done == true)
                    return null;
                    while (fuel == null || fuel > 0) {
                        if (stack.length > 0) {
                            var workFunc = stack.pop();
                            if (workFunc != null)
                            workFunc(calcState);
                        } else {
                            if (visitCell(calcState, row, col) == true) {
                                done = true;
                                return null;
                            }

                            if (col >= cellProvider.getNumberOfColumns(row)) {
                                row = row + 1;
                                col = 1;
                            } else {
                            col = col + 1};
                            // Sweep through columns first.

                        }
                        if (fuel != null){
							fuel -= 1};
                    }
                }
                return calcState.calcMore;
            }
            var visitCell = function(calcState, r, c) {
                // Returns true if done with all cells.
                with(calcState) {
                    var cell = cellProvider.getCell(r, c);
                    if (cell == null)
                    return true;

                    var value = cell.getValue();
                    if (value == null) {
                        var formula = cell.getFormula();
                        if (formula != null) {
                            var firstChar = formula.charAt(0);
                            if (firstChar == '=') {
                                var formulaFunc = cell.getFormulaFunc();
                                if (formulaFunc == null || 
                                formulaFunc.formula != formula) {
                                    formulaFunc = null;
                                    try {
                                        var dependencies = {};
                                        var body = parseFormula(formula.substring(1), dependencies);
                                        formulaFunc = safeEval("var jSheet_spreadsheet_formula = " + 
                                        "function(__CELL_PROVIDER, __CONTEXT, __STD_FUNCS) { " + 
                                        "with (__CELL_PROVIDER) { with (__STD_FUNCS) { " + 
                                        "with (__CONTEXT) { return (" + body + "); } } } }; jSheet_spreadsheet_formula");
                                        formulaFunc.formula = formula;
                                        formulaFunc.dependencies = dependencies;
                                        cell.setFormulaFunc(formulaFunc);
                                    } catch(e) {
                                        cell.setValue(eng.ERROR, e);
                                    }
                                }
                                if (formulaFunc != null) {
                                    stack.push(makeFormulaEval(r, c));

                                    // Push the cell's dependencies, first checking for any cycles. 
                                    var dependencies = formulaFunc.dependencies;
                                    for (var k in dependencies) {
                                        if (checkCycles(stack, dependencies[k][0], dependencies[k][1]) == true) {
                                            cell.setValue(eng.ERROR, "cycle detected");
                                            stack.pop();
                                            return false;
                                        }
                                    }
                                    for (var k in dependencies)
                                    stack.push(makeCellVisit(dependencies[k][0], dependencies[k][1]));
                                }
                            } else {
	                            cell.setValue(parseFormulaStatic(formula));}
                        }
                    }
                }
                return false;
            }

            var makeCellVisit = function(row, col) {
                var func = function(calcState) {
                    return visitCell(calcState, row, col);
                };
                func.row = row;
                func.col = col;
                return func;
            }

            var makeFormulaEval = function(row, col) {
                var func = function(calcState) {
                    var cell = calcState.cellProvider.getCell(row, col);
                    if (cell != null) {
                        var formulaFunc = cell.getFormulaFunc();
                        if (formulaFunc != null) {
                            try {
                                cell.setValue(formulaFunc(calcState.cellProvider, calcState.context, eng.standardFunctions));

                            } catch(e) {
                                cell.setValue(eng.ERROR, e);
                            }
                        }
                    }
                }
                func.row = row;
                func.col = col;
                return func;
            }

            // Parse formula (without "=" prefix) like "123+SUM(A1:A6)/D5" into JavaScript expression string.
            var parseFormula = jSheet.TEST.parseFormula = function(formula, dependencies) {
                var arrayReferencesFixed = formula.replace(/\$?([A-Z]+)\$?([0-9]+):\$?([A-Z]+)\$?([0-9]+)/g, 
                function(ignored, startColStr, startRowStr, endColStr, endRowStr) {
                    var res = [];
                    var startCol = columnLabelIndex(startColStr);
                    var startRow = theParseInt(startRowStr);
                    var endCol = columnLabelIndex(endColStr);
                    var endRow = theParseInt(endRowStr);
                    for (var r = startRow; r <= endRow; r++)
                    for (var c = startCol; c <= endCol; c++)
                    res.push(columnLabelString(c) + r);
                    return "[" + res.join(",") + "]";
                });
                var result = arrayReferencesFixed.replace(/\$?([A-Z]+)\$?([0-9]+)/g, 
                function(ignored, colStr, rowStr) {
                    if (dependencies != null)
                    dependencies[colStr + rowStr] = [theParseInt(rowStr), columnLabelIndex(colStr)];
                    return "(getCell((" + rowStr + "),'" + colStr + "').getValue())";

                });
                return result;
            }

            // Parse static formula value like "123.0" or "hello" or "'hello world" into JavaScript value.
            var parseFormulaStatic = eng.parseFormulaStatic = function(formula) {
                var value = theParseFloat(formula);
                if (theIsNaN(value))
                value = theParseInt(formula);
                if (theIsNaN(value))
                value = (formula.charAt(0) == "'" ? formula.substring(1) : formula);
                return value;
            }

            var checkCycles = function(stack, row, col) {
                for (var i = 0; i < stack.length; i++) {
                    var item = stack[i];
                    if (item.row != null && item.col != null && 
                    item.row == row && item.col == col)
                    return true;
                }
                return false;
            }

            var fold = function(arr, funcOfTwoArgs, result) {
                for (var i = 0; i < arr.length; i++)
                result = funcOfTwoArgs(result, arr[i]);
                return result;
            }
            var SUM2 = function(x, y) {
                return x + y;
            }
            var MAX2 = function(x, y) {
                return x > y ? x: y;
            }
            var MIN2 = function(x, y) {
                return x < y ? x: y;
            }
            var COUNT2 = function(x, y) {
                return (y != null) ? x + 1: x;
            }

            // Cells don't know their coordinates, to make shifting easier.
            //
            eng.Cell.prototype.getError = function() {
                return this.error;
            };
            eng.Cell.prototype.getValue = function() {
                return this.value;
            };
            eng.Cell.prototype.setValue = function(v, e) {
                this.value = v;
                this.error = e;
            };

            eng.Cell.prototype.getFormat = function() {
                return this.format;
            };
            // Like "#,###.##".  The format != style.
            eng.Cell.prototype.setFormat = function(v) {
                this.format = v;
            };
            eng.Cell.prototype.getFormula = function() {
                return this.formula;
            };
            // Like "=1+2+3" or "'hello" or "1234.5"
            eng.Cell.prototype.setFormula = function(v) {
                this.formula = v;
            };
            eng.Cell.prototype.getFormulaFunc = function() {
                return this.formulaFunc;
            };
            eng.Cell.prototype.setFormulaFunc = function(v) {
                this.formulaFunc = v;
            };

            eng.Cell.prototype.toString = function() {
                return "Cell:[" + this.getFormula() + ": " + this.getValue() + ": " + this.getError() + "]";
            }

            var columnLabelString = eng.columnLabelString = function(index) {
                // The index is 1 based.  Convert 1 to A, 2 to B, 25 to Y, 26 to Z, 27 to AA, 28 to AB.
                // TODO: Got a bug when index > 676.  675==YZ.  676==YZ.  677== AAA, which skips ZA series.
                //	   In the spirit of billg, who needs more than 676 columns anyways?
                var b = (index - 1).toString(26).toUpperCase();
                // Radix is 26.
                var c = [];
                for (var i = 0; i < b.length; i++) {
                    var x = b.charCodeAt(i);
                    if (i <= 0 && b.length > 1)
                    // Leftmost digit is special, where 1 is A.
                    x = x - 1;
                    if (x <= 57)
                    // x <= '9'.
                    c.push(String.fromCharCode(x - 48 + 65));
                    // x - '0' + 'A'.
                    else
                    c.push(String.fromCharCode(x + 10));
                }
                return c.join("");
            }

            var columnLabelIndex = eng.columnLabelIndex = function(str) {
                // Converts A to 1, B to 2, Z to 26, AA to 27.
                var num = 0;
                for (var i = 0; i < str.length; i++) {
                    var digit = str.charCodeAt(i) - 65 + 1;
                    // 65 == 'A'.
                    num = (num * 26) + digit;
                }
                return num;
            }

            var parseLocation = eng.parseLocation = function(locStr) {
                // With input of "A1", "B4", "F20",
                if (locStr != null && 
                // will return [1,1], [4,2], [20,6].
                locStr.length > 0) {
                    for (var firstNum = 0; firstNum < locStr.length; firstNum++)
                    if (locStr.charCodeAt(firstNum) <= 57)
                    // 57 == '9'
                    break;
                    return [theParseInt(locStr.substring(firstNum)), 
                    columnLabelIndex(locStr.substring(0, firstNum))];
                }
                return null;
            }
        })(function(str) {
            return eval(str);
        });
        // The safeEval occurs only in outer, global scope.
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////End Core
        var jSheet;

        (function() {
            // Using a closure to keep global namespace clean.
            var theMath = Math;
            var theIsNaN = isNaN;
            var theParseInt = parseInt;

            if (jSheet == null)
            jSheet = new Object();
            if (jSheet.TEST == null)
            jSheet.TEST = new Object();
            // For exposing to testing only.
			//////////////////////////////////////////////////////////////////////////////
            // This file depends on spreadsheet_engine.js.  It holds all UI related code
            // and dependencies on a DOM/DHTML environment.
            //
            // Coding/design note: we've tried mightily to not hold onto any DOM 
            // objects or nodes as state in our code due to IE's infamous memory leak.  
            // See http://jSheet.com/project/wiki/InelegantJavaScript
            //
            var log = function(msg) {
                if (document != null) {
                    var log = $("#jSheet_log");
                    if (log) {
                        log.appendChild(document.createTextNode(msg));
                        log.appendChild(document.createElement("BR"));

                    }

                }

            }

            var makeEventHandler = function(handler) {
                return function(evt) {
                    evt = (evt) ? evt: ((window.event) ? window.event: null);
                    if (evt) {
                        var target = (evt.target) ? evt.target: evt.srcElement;
                        return handler(evt, target);

                    }

                }

            }

            var spreadsheet = jSheet.spreadsheet = {
                ERROR: jSheet.spreadsheetEngine.ERROR,
                DEFAULT_ROW_HEADER_WIDTH: "30px",

				initDocument: function(doc) {
                    if (doc == null)
                    doc = document;
                    $('table[@class*="spreadsheet"]').each(function() {
                        spreadsheet.decorateSpreadsheet(this, doc);

                    });

                },
                decorateSpreadsheet: function(tableBody, doc) {
                    if (doc == null) {
                        doc = document;

                    }
                    if ($(tableBody).attr('id') == null || $(tableBody).attr('id').length <= 0) {
                        $(tableBody).attr('id', genId("spreadsheet"));

                    }

                    var filterForFirstColumn = function(node) {
                        // Keeps the first td/th of each tr.
                        if (node.nodeType != 1) {
                            return true;
                        }
                        if ((node.tagName == "COL") && 
                        (node.parentNode == tableBody || 
                        // Mozilla has TABLE.COL structure.
                        node.parentNode.parentNode == tableBody))
                        // IE has TABLE.COLGROUP.COL structure.
                        return isFirstChild(node);
                        if ((node.parentNode.parentNode.parentNode == tableBody) && 
                        (node.tagName == "TD" || node.tagName == "TH"))
                        return isFirstChild(node);
                        return true;

                    }

                    var filterForTHEAD = function(node) {
                        // Keeps thead, col, colgroup, but not tbody and tfoot.
                        if (node.nodeType != 1)
                        return true;
                        if ((node.parentNode == tableBody) && 
                        (node.tagName == "TBODY" || 
                        node.tagName == "TFOOT"))
                        return false;
                        return true;

                    }

                    // Categorize the parents of tableBody.
                    var parents = {
                        spreadsheetEditor: null,
                        spreadsheetScroll: null,
                        spreadsheetBars: null
                    };
                    categorizeParents(tableBody, parents);

                    with(parents) {
                        if (spreadsheetBars != null) {
                            if (spreadsheetBars.id == null || 
                            spreadsheetBars.id.length <= 0)
                            spreadsheetBars.id = tableBody.id + "_spreadsheetBars";

                            // Add row & column headers to tableBody, if not already.
                            if (tableBody.rows[0] != null && 
                            tableBody.rows[0].cells[0] != null && 
                            !isBarItem(tableBody.rows[0].cells[0])) {
                                // Prepend a new row for column headers.
                                var row = doc.createElement("TR");
                                row.id = tableBody.id + "_spreadsheetBar";

                                for (var cell, i = 0; i < tableBody.rows[0].cells.length + 1; i++) {
                                    cell = doc.createElement("TH");
                                    cell.className = "spreadsheetBarItem";
                                    cell.innerHTML = (i <= 0) ? "&nbsp;": jSheet.spreadsheetEngine.columnLabelString(i);
                                    row.appendChild(cell);

                                }

                                var thead = tableBody.getElementsByTagName("THEAD")[0];
                                if (thead == null) {
                                    thead = doc.createElement("THEAD");
                                    tableBody.insertBefore(thead, (tableBody.rows[0] != null ? tableBody.rows[0].parentNode: tableBody.firstChild));

                                }
                                thead.insertBefore(row, thead.firstChild);

                                // Prepend row headers to each row.
                                for (var cell, i = 1; i < tableBody.rows.length; i++) {
                                    cell = doc.createElement("TH");
                                    cell.className = "spreadsheetBarItem";
                                    cell.innerHTML = i;
                                    cell = tableBody.rows[i].insertBefore(cell, tableBody.rows[i].cells[0]);

                                }

                                // Prepend one colgroup/col element that covers the new row headers.
                                var cols = tableBody.getElementsByTagName("COL");
                                if (cols != null && 
                                cols.length > 0) {
                                    var col = doc.createElement("COL");
                                    col.className = "spreadsheetBarItem";
                                    col.setAttribute("width", spreadsheet.DEFAULT_ROW_HEADER_WIDTH);
                                    cols[0].parentNode.insertBefore(col, cols[0]);
                                }
                            }

                            // Copy a truncated tableBody to be the spreadsheetBarLeft.
                            var spreadsheetBarLeft = doc.getElementById(spreadsheetBars.id + "_spreadsheetBarLeft");
                            if (spreadsheetBarLeft == null) {
                                spreadsheetBarLeft = copyNodeTree(tableBody, filterForFirstColumn, doc);
                                spreadsheetBarLeft.id = spreadsheetBars.id + "_spreadsheetBarLeft";
                                spreadsheetBarLeft.className = "spreadsheetBarLeft";
                                spreadsheetBarLeft.width = "";
                                // Let browser calculate smallest width.
                                $(tableBody.rows).each(function(i) {// Synchronize row heights.
                                    spreadsheetBarLeft.rows[i].style.height = tableBody.rows[i].clientHeight;

                                });
                                $(spreadsheetBars).append(spreadsheetBarLeft);

                            }

                            for (var i = 1; i < spreadsheetBarLeft.rows.length; i++)
                            spreadsheetBarLeft.rows[i].onmousedown = rowResizer.start;

                            // Copy a truncated tableBody to be the spreadsheetBarTop.
                            var spreadsheetBarTop = doc.getElementById(spreadsheetBars.id + "_spreadsheetBarTop");
                            if (spreadsheetBarTop == null) {
                                spreadsheetBarTop = copyNodeTree(tableBody, filterForTHEAD, doc);
                                spreadsheetBarTop.id = spreadsheetBars.id + "_spreadsheetBarTop";
                                spreadsheetBarTop.className = "spreadsheetBarTop";
                                spreadsheetBars.appendChild(spreadsheetBarTop);

                            }

                            for (var cells = spreadsheetBarTop.rows[0].cells, i = 1; i < cells.length; i++)
                            cells[i].onmousedown = columnResizer.start;

                            // Copy a truncated tableBody to be the spreadsheetBarCorner.
                            var spreadsheetBarCorner = doc.getElementById(spreadsheetBars.id + "_spreadsheetBarCorner");
                            if (spreadsheetBarCorner == null) {
                                spreadsheetBarCorner = copyNodeTree(tableBody, 
                                function(node) {
                                    return filterForFirstColumn(node) && filterForTHEAD(node);
                                },
                                doc);
                                spreadsheetBarCorner.id = spreadsheetBars.id + "_spreadsheetBarCorner";
                                spreadsheetBarCorner.className = "spreadsheetBarCorner";
                                spreadsheetBarCorner.width = "";
                                spreadsheetBars.appendChild(spreadsheetBarCorner);
                            }

                            $(tableBody.rows).each(function() {
                                // Hidden so that underlying tableBody bars
                                this.cells[0].style.visiblity = "hidden";
                                // don't show during resizing columns/rows.
                            });
                            tableBody.rows[0].style.visibility = "hidden";
                        }

                        if (spreadsheetScroll != null) {
                            if (spreadsheetScroll.id == null || 
                            spreadsheetScroll.id.length <= 0)
                            spreadsheetScroll.id = tableBody.id + "_spreadsheetScroll";
                            spreadsheetScroll.onscroll = spreadsheetScroll.onresize = makeBarAdjustor(tableBody.id);
                            spreadsheetScroll.onscroll();
                        }

                        if (spreadsheetEditor != null) {
                            if (spreadsheetEditor.id == null || 
                            spreadsheetEditor.id.length <= 0)
                            spreadsheetEditor.id = tableBody.id + "_spreadsheetEditor";

                            // Populate the controls.
                            var controls = doc.getElementById(spreadsheetEditor.id + "_spreadsheetControls");
                            if (controls == null) {
                                controls = doc.createElement("DIV");
                                controls.id = spreadsheetEditor.id + "_spreadsheetControls";
                                controls.className = "spreadsheetControls";
                                // Adding as a sibling, because adding as a child of spreadsheetEditor
                                // makes the controls scroll for some reason.
                                spreadsheetEditor.insertBefore(controls, spreadsheetEditor.firstChild);

                            }
                            $(controls)
								.append('<span class="spreadsheetLocation" id="' + controls.id + '_loc"></span>')
								.append('<label class="spreadsheetFormulaLabel" for=' + controls.id + '_formula">fx</label>')
								.append('<input class="spreadsheetFormula" name="' + controls.id + '_formula" id="' + controls.id + '_formula" size="50"/>')
								.append('<span id="texteffects" class="spreadsheetStyle spreadsheetStyleFont"></span>')
								.append('<span id="textalignment" class="spreadsheetStyle spreadsheetStyleAlign"></span>')
								.append('<input type="button" id="reg" value="View Source">')
								.append('<input type="button" id="pret" value="View Pretty Source">');
								
							$('#texteffects')
								.append('<a href="#fontWeight:bold" class="Sheetstyler"><b>B</b></a>')
								.append('<a href="#fontStyle:italic" class="Sheetstyler"><i>I</i></a>')
								.append('<a href="#textDecoration:underline" style="text-decoration: underline;" class="Sheetstyler">U</a>');
                            
							$('#textalignment')
								.append('<a href="#textAlign:left" class="spreadsheetStyleAlignLeft Sheetstyler">Left</a>')
								.append('<a href="#textAlign:center" class="spreadsheetStyleAlignCenter Sheetstyler">Center</a>')
								.append('<a href="#textAlign:right" class="spreadsheetStyleAlignRight Sheetstyler">Right</a>');
							
							$('#'+controls.id).keydown(function(e){
								jSheet.spreadsheet.formulaKeyDown(e);
							});
							
							$(".Sheetstyler").click(function(e){
								jSheet.spreadsheet.styleToggle(e);
							});
							
                            // Register onclick for tableBody td elements.
                            $('#t1_spreadsheetBars tr td').each(function() {
                                this.onclick = cellOnClick;
                            });
                        }
                    }

                    if (!isClass(tableBody, "spreadsheetCalcOff"))
                    jSheet.spreadsheet.calc(tableBody);
                },
                undecorateSpreadsheet: function(tableBody, doc) {
                    if (doc == null)
                    doc = document;
                    if (tableBody != null && 
                    tableBody.id != null) {
                        if (doc.getElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarCorner") != null) {
                            for (var ths = tableBody.getElementsByTagName("TH"), i = ths.length - 1; i >= 0; i--)
                            if (isBarItem(ths[i]))
                            ths[i].parentNode.removeChild(ths[i]);
                            var cols = tableBody.getElementsByTagName("COL");
                            cols[0].parentNode.removeChild(cols[0]);
                        }
                        removeElementById(tableBody.id + "_spreadsheetBar", doc);
                        removeElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarTop", doc);
                        removeElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarLeft", doc);
                        removeElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarCorner", doc);
                        removeElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls", doc);
                    }
                },
                cellEdit: function(tableBody, row, col, td, labelLocation, inputFormula) {
                    // The row and col are 1-based.
                    if (tableBody != null) {
                        // This method points the controls to a new cell.
                        if (td == null)
                        td = getTd(tableBody, row, col);
                        if (td != null) {
                            if (labelLocation == null)
                            labelLocation = document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_loc");
                            if (inputFormula == null)
                            inputFormula = document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_formula");
                            jSheet.spreadsheet.cellEditDone(tableBody, labelLocation, inputFormula);
                            if (labelLocation != null)
                            labelLocation.innerHTML = jSheet.spreadsheetEngine.columnLabelString(col) + row;
                            if (inputFormula != null) {
                                var v = td.getAttribute("formula");
                                if (v == null || 
                                v.length <= 0)
                                v = td.innerHTML;
                                inputFormula.value = v;
                                inputFormula.select();
                                inputFormula.focus();
                            }

                            setActive(tableBody, td);
                        }
                    }
                },
                cellEditDone: function(tableBody, labelLocation, inputFormula, bClearActive) {
                    // Any changes to the input controls are stored back into the table, with a recalc.
                    if (labelLocation == null)
                    labelLocation = document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_loc");
                    if (inputFormula == null)
                    inputFormula = document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_formula");
                    if (labelLocation != null && 
                    inputFormula != null) {
                        var loc = jSheet.spreadsheetEngine.parseLocation(labelLocation.innerHTML);
                        if (loc != null) {
                            var td = getTd(tableBody, loc[0], loc[1]);
                            if (td != null) {
                                var recalc = false;
                                var v = inputFormula.value;
                                if (v.length > 0) {
                                    if (v.charAt(0) == '=') {
                                        if (v != td.getAttribute("formula")) {
                                            recalc = true;
                                            td.innerHTML = "";
                                            td.setAttribute("formula", v);
                                        }
                                    } else {
                                        if (v != td.innerHTML) {
                                            recalc = true;
                                            td.innerHTML = v;
                                            td.removeAttribute("formula");
                                        }
                                    }
                                } else {
                                    if (td.innerHTML.length > 0 || 
                                    td.getAttribute("formula") != null) {
                                        recalc = true;
                                        td.innerHTML = "";
                                        td.removeAttribute("formula");
                                    }
                                }
                                if (bClearActive != false)
                                // Treats null == true.
                                clearActive(tableBody, td);

                                if (recalc && !isClass(tableBody, "spreadsheetCalcOff"))
                                jSheet.spreadsheet.calc(tableBody);
                            }
                        }
                    }
                },
                cellEditAbandon: function(tableBody, labelLocation, inputFormula) {
                    if (labelLocation == null)
                    labelLocation = document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_loc");
                    if (inputFormula == null)
                    inputFormula = document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_formula");
                    if (labelLocation != null && 
                    inputFormula != null) {
                        var loc = jSheet.spreadsheetEngine.parseLocation(labelLocation.innerHTML);
                        if (loc != null)
                        clearActive(tableBody, getTd(tableBody, loc[0], loc[1]));
                        labelLocation.innerHTML = "";
                        inputFormula.value = "";
                    }
                },
                formulaKeyDown: makeEventHandler(function(evt, inputFormula) {
                    var tableBody = document.getElementById(inputFormula.id.split('_')[0]);
                    if (tableBody != null) {
                        if (evt.keyCode == 27) {
                            // ESC key.
                            jSheet.spreadsheet.cellEditAbandon(tableBody, null, inputFormula);
                            return false;
                        }
                        if (evt.keyCode == 13) {
                            // ENTER key.
                            jSheet.spreadsheet.cellEditDone(tableBody, null, inputFormula, false);
                            return false;
                        }
                    }
                    return true;
                }),
                styleToggle: makeEventHandler(function(evtIgnored, aLink, tableBody, td, action) {
                    aLink = getParent(aLink, "A");
                    if (tableBody == null)
                    tableBody = document.getElementById(getParent(aLink, "DIV").id.split("_")[0]);
                    if (tableBody != null) {
                        if (td == null) {
                            var loc = jSheet.spreadsheetEngine.parseLocation(document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_loc").innerHTML);
                            if (loc != null)
                            td = getTd(tableBody, loc[0], loc[1]);
                        }
                        if (td != null) {
                            if (action == null)
                            action = aLink.href.split('#')[1];
                            // Example: fontWeight:bold.
                            if (action != null && 
                            action.length > 0) {
                                var actionSplit = action.split(':');
                                if (td.style[actionSplit[0]] != actionSplit[1])
                                td.style[actionSplit[0]] = actionSplit[1];
                                else
                                td.style[actionSplit[0]] = "";
                            }
                        }
                    }
                    return false;
                }),
                context: {},
                calc: function(tableBody, fuel) {
                    return jSheet.spreadsheetEngine.calc(new TableCellProvider(tableBody.id), jSheet.spreadsheet.context, fuel);
                },
                showFormulas: function(tableBody) {
                    for (var i = 0; i < tableBody.rows.length; i++) {
                        for (var tr = tableBody.rows[i], j = 0; j < tr.cells.length; j++) {
                            var formula = tr.cells[j].getAttribute("formula");
                            if (formula != null && 
                            formula != "")
                            tr.cells[j].innerHTML = formula;
                        }
                    }
                }
            }
            var cellOnClick = makeEventHandler(function(evtIgnored, target) {
                var td = getParent(target, "TD");
                if (td != null) {
                    var loc = getTdLocation(td);
                    var tableBody = getParent(td, "TABLE");
                    if (tableBody != null && loc != null) {
                        var labelLocation = document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_loc");
                        var inputFormula = document.getElementById(tableBody.id + "_spreadsheetEditor_spreadsheetControls_formula");
                        if (labelLocation != null && 
                        labelLocation.innerHTML.length > 0 && 
                        inputFormula != null && 
                        inputFormula.value.length > 0 && 
                        inputFormula.value.charAt(0) == '=') {
                            if ("=([:,*/+-".indexOf(inputFormula.value.charAt(inputFormula.value.length - 1)) >= 0) {
                                // Append cell location to currently edited formula based on mouse click.
                                inputFormula.value += jSheet.spreadsheetEngine.columnLabelString(loc[1]) + loc[0];
                                inputFormula.select();
                                // TODO: We should actually move the caret to the end.
                                inputFormula.focus();
                                //	   But, don't know how to do that cross-browser yet.
                                return false;
                            }
                        }
                        jSheet.spreadsheet.cellEdit(getParent(td, "TABLE"), loc[0], loc[1], td, labelLocation, inputFormula);
                    }
                }
            });

            var dragInfo = {};

            var makeBarResizer = function(xyDimension, clientAttr, thIndexGetter, thPreviousGetter, 
            barItemsGetter, firstTHGetter, barItemSizeGetter, barItemSizeSetter, 
            tableSizeGetter, tableSizeSetter) {
                var barResizer = {
                    start: makeEventHandler(function(evt, target) {
                        var thEl = getParent(target, "TH");
                        if (thEl != null) {
                            var barTable = getParent(thEl, "TABLE");
                            if (barTable != null) {
                                var tableBody = $("#"+barTable.id.split("_"));
                                if (tableBody != null) {
                                    var scrollOffsetXY = [0, 0];
                                    var spreadsheetScroll = document.getElementById(tableBody.id + "_spreadsheetScroll");
                                    if (spreadsheetScroll != null)
                                    scrollOffsetXY = [spreadsheetScroll.scrollLeft, spreadsheetScroll.scrollTop];

                                    var thPageXY,
                                    edgeDelta,
                                    eventPageXY = findEventPageXY(evt, scrollOffsetXY);
                                    while (thEl != null && thIndexGetter(thEl) > 0) {
                                        thPageXY = findElementPageXY(thEl);
                                        edgeDelta = thPageXY[xyDimension] + thEl[clientAttr] - eventPageXY[xyDimension];
                                        if (theMath.abs(edgeDelta) <= 3)
                                        break;
                                        thEl = thPreviousGetter(thEl);

                                    }
                                    if (thEl != null && thIndexGetter(thEl) > 0) {
                                        jSheet.spreadsheet.cellEditDone(tableBody);
                                        dragInfo = {
                                            barTable: barTable,
                                            // TODO: IE mem leak here?
                                            barItems: barItemsGetter(barTable),
                                            // TODO: IE mem leak here?
                                            barPageXY: findElementPageXY(firstTHGetter(barTable)),
                                            // The pageXY of the first non-corner TH.
                                            edgeDelta: edgeDelta,
                                            startIndex: thIndexGetter(thEl),
                                            startSizes: [],
                                            scrollOffsetXY: scrollOffsetXY
                                        };
                                        $(dragInfo.barItems).each(function(i) {
                                            dragInfo.startSizes[i] = theParseInt(barItemSizeGetter(dragInfo.barItems[i]));
                                            if (theIsNaN(dragInfo.startSizes[i]))
                                            return;
                                        });
                                        document.onmousemove = barResizer.drag;
                                        document.onmouseup = barResizer.stop;
                                        return false;
                                    }
                                }
                            }
                        }
                    }),
                    drag: makeEventHandler(function(evt, target) {
                        if (dragInfo.barTable != null) {
                            var newSizes = $(dragInfo.startSizes).slice(0);
                            // Make a copy.
                            var v = findEventPageXY(evt, dragInfo.scrollOffsetXY)[xyDimension] - dragInfo.barPageXY[xyDimension] + dragInfo.edgeDelta;
                            if (v > 0) {
                                for (var sizeTotal = 0, i = 1; i < dragInfo.startIndex; i++) {
                                    if ((sizeTotal + newSizes[i]) > v)
                                    newSizes[i] = theMath.max(v - sizeTotal, 3);
                                    // A non-zero minimum size saves many headaches.
                                    sizeTotal += newSizes[i];
                                }
                                newSizes[dragInfo.startIndex] = theMath.max(v - sizeTotal, 3);
                                // A non-zero minimum size saves many headaches.
                            }
                            for (var sizeTotal = 0, i = 1; i < newSizes.length; i++) {
                                sizeTotal += newSizes[i];
                                barItemSizeSetter(dragInfo.barItems[i], newSizes[i] + "px");
                            }
                            tableSizeSetter(dragInfo.barTable, sizeTotal + "px");
                            return false;
                        }

                    }),
                    stop: makeEventHandler(function(evt, target) {
                        if (dragInfo.barTable != null) {
                            var tableBody = document.getElementById(dragInfo.barTable.id.split("_")[0]);
                            if (tableBody != null) {
                                var redecorate = false;
                                var srcItems = barItemsGetter(dragInfo.barTable);
                                var dstItems = barItemsGetter(tableBody);

                                $(dstItems).each(function(i) {
                                    var size = barItemSizeGetter(srcItems[i]);
                                    if (size != barItemSizeGetter(dstItems[i])) {
                                        barItemSizeSetter(dstItems[i], size);
                                        redecorate = true;
                                    }
                                });

                                tableSizeSetter(tableBody, tableSizeGetter(dragInfo.barTable) + "px");

                                if (redecorate) {
                                    jSheet.spreadsheet.undecorateSpreadsheet(tableBody);
                                    jSheet.spreadsheet.decorateSpreadsheet(tableBody);
                                }
                            }
                        }
                        dragInfo = {};
                        document.onmousemove = document.onmouseup = null;
                        return false;
                    })
                }
                return barResizer;
            }

            var columnResizer = makeBarResizer(0, "clientWidth", 
            function(th) {
                return th.cellIndex;
            },
            function(th) {
                return th.parentNode.cells[th.cellIndex - 1];
            },
            function(barTable) {
                return barTable.getElementsByTagName("COL");
            },
            function(barTable) {
                return barTable.rows[0].cells[1];
            },
            function(barItem) {
                return barItem.getAttribute("width");
            },
            function(barItem, v) {
                barItem.setAttribute("width", v);
            },
            function(barTable) {
                return barTable.getAttribute("width");
            },
            function(barTable, v) {
                barTable.setAttribute("width", v);
            });

            var rowResizer = makeBarResizer(1, "clientHeight", 
            function(th) {
                return th.parentNode.rowIndex;
            },
            function(th) {
                return th.parentNode.parentNode.parentNode.rows[th.parentNode.rowIndex - 1].cells[0];
            },
            function(barTable) {
                return barTable.rows;
            },
            function(barTable) {
                return barTable.rows[1].cells[0];
            },
            function(barItem) {
                var height = $(barItem).css('height');
                return (height != null && height != "") ? height: barItem.clientHeight + "px";
            },
            function(barItem, v) {
                barItem.style.height = v;
            },
            function(el) {
                return - 1;
            },
            function(el, v) {});

            var dumpCoords = function(str, evt, target) {
                var evtPageXY = findEventPageXY(evt, [0, 0]);
                log(str + ": " + target.tagName + ": " + target.className + " evtPageXY: " + evtPageXY[0] + ", " + evtPageXY[1]);
            }

            var findEventPageXY = function(evt, scrollOffsetXY) {
                if (evt.offsetX || evt.offsetY) {
                    var targetPageXY = findElementPageXY((evt.target) ? evt.target: evt.srcElement);
                    return [evt.offsetX + targetPageXY[0], evt.offsetY + targetPageXY[1]];
                }
                if (scrollOffsetXY == null)
                // The scrollOffsetXY hack is because Mozilla's pageXY doesn't handle scrolled divs.
                scrollOffsetXY = [0, 0];
                if (evt.pageX || evt.pageY)
                return [evt.pageX + scrollOffsetXY[0], evt.pageY + scrollOffsetXY[1]];
                return [evt.clientX + document.body.scrollLeft, evt.clientY + document.body.scrollTop];
            }

            var findElementPageXY = function(obj) {
                // From ppk quirksmode.org.
                var point = [0, 0];
                if (obj.offsetParent) {
                    while (obj.offsetParent) {
                        point[0] += obj.offsetLeft;
                        point[1] += obj.offsetTop;
                        obj = obj.offsetParent;
                    }
                } else if (obj.x)
                return [obj.x, obj.y];
                return point;
            }

            var setActive = function(tableBody, td) {
                if (tableBody != null && 
                td != null) {
                    td.className += (td.className.length <= 0 ? "spreadsheetCellActive": " spreadsheetCellActive");
                    if (document.getElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarCorner") != null) {
                        var barItem = document.getElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarLeft").rows[td.parentNode.rowIndex].cells[0];
                        barItem.className += (barItem.className <= 0 ? "spreadsheetBarItemSelected": " spreadsheetBarItemSelected");
                        var barItem = document.getElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarTop").rows[0].cells[td.cellIndex];
                        barItem.className += (barItem.className <= 0 ? "spreadsheetBarItemSelected": " spreadsheetBarItemSelected");
                    }
                }
            }

            var clearActive = function(tableBody, td) {
                if (tableBody != null && 
                td != null) {
                    td.className = td.className.replace(/\s*spreadsheetCellActive/g, "");
                    if (document.getElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarCorner") != null) {
                        var barItem = document.getElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarLeft").rows[td.parentNode.rowIndex].cells[0];
                        barItem.className = barItem.className.replace(/\s*spreadsheetBarItemSelected/g, "");
                        var barItem = document.getElementById(tableBody.id + "_spreadsheetBars_spreadsheetBarTop").rows[0].cells[td.cellIndex];
                        barItem.className = barItem.className.replace(/\s*spreadsheetBarItemSelected/g, "");
                    }
                }
            }

            var getIndexTr = function(tableBody, row) {
                // The row is 1-based.
                if (isBarItem(tableBody.rows[0].cells[0]))
                row++;
                return row - 1;
                // A indexTr is 0-based.
            }

            var getIndexTd = function(tableBody, indexTr, col) {
                // The col is 1-based.
                var tr = tableBody.rows[indexTr];
                // A indexTr is 0-based.
                if (tr != null && 
                isBarItem(tr.cells[0]))
                col++;
                return col - 1;
                // A indexTd is 0-based.
            }

            var getTd = function(tableBody, row, col, indexTr, indexTd) {
                // The row and col are 1-based.
                if (indexTr == null)
                // The indexTr and indexTd are 0-based.
                indexTr = getIndexTr(tableBody, row);
                var tr = tableBody.rows[indexTr];
                if (tr != null) {
                    if (indexTd == null)
                    indexTd = getIndexTd(tableBody, indexTr, col);
                    return tr.cells[indexTd];
                }
                return null;
            }

            var getTdLocation = function(td) {
                var col = td.cellIndex + 1;
                if (isBarItem(td.parentNode.cells[0]))
                col--;
                var row = td.parentNode.rowIndex + 1;
                if (isBarItem(getParent(td, "TABLE").rows[0].cells[0]))
                row--;
                return [row, col];
                // The row and col are 1-based.
            }

            var TableCellProvider = function(tableBodyId) {
                this.tableBodyId = tableBodyId;
                this.cells = {};
            }

            TableCellProvider.prototype.getCell = function(row, col) {
                if (typeof(col) == "string")
                col = jSheet.spreadsheetEngine.columnLabelIndex(col);
                var key = row + "," + col;
                var cell = this.cells[key];
                if (cell == null) {
                    var tableBody = document.getElementById(this.tableBodyId);
                    if (tableBody != null) {
                        var td = getTd(tableBody, row, col);
                        if (td != null)
                        cell = this.cells[key] = new TableCell(tableBody, row, col);
                    }
                }
                return cell;
            }

            TableCellProvider.prototype.getNumberOfColumns = function(row) {
                var tableBody = document.getElementById(this.tableBodyId);
                if (tableBody != null) {
                    var tr = tableBody.rows[getIndexTr(tableBody, row)];
                    if (tr != null) {
                        if (isBarItem(tr.cells[0]))
                        return tr.cells.length - 1;
                        return tr.cells.length;
                    }
                }
                return 0;
            }

            TableCellProvider.prototype.toString = function() {
                var tableBody = document.getElementById(this.tableBodyId);
                for (var result = "", i = 0; i < tableBody.rows.length; i++)
                result += tableBody.rows[i].innerHTML.replace(/\n/g, "") + "\n";
                return result;
            }

            var EMPTY_VALUE = {};

            var TableCell = function(tableBody, row, col) {
                this.tableBodyId = tableBody.id;
                this.row = row;
                this.col = col;
                this.indexTr = getIndexTr(tableBody, row);
                this.indexTd = getIndexTd(tableBody, this.indexTr, col);
                this.value = EMPTY_VALUE;
                // Cache of value, where "real" value is a string in the TD.innerHTML.
            }
            TableCell.prototype = new jSheet.spreadsheetEngine.Cell();
            TableCell.prototype.getTd = function() {
                return getTd(document.getElementById(this.tableBodyId), this.row, this.col, this.indexTr, this.indexTd);
            }

            TableCell.prototype.setValue = function(v, e) {
                this.error = e;
                this.value = v;
                this.getTd().innerHTML = (v != null ? v: "");

            }
            TableCell.prototype.getValue = function() {
                var v = this.value;
                if (v === EMPTY_VALUE && this.getFormula() == null) {
                    v = this.getTd().innerHTML;
                    v = this.value = (v.length > 0 ? jSheet.spreadsheetEngine.parseFormulaStatic(v) : null);

                }
                return (v === EMPTY_VALUE ? null: v);
            }

            TableCell.prototype.getFormat = function() {
                return this.getTd().getAttribute("format");
            };
            TableCell.prototype.setFormat = function(v) {
                this.getTd().setAttribute("format", v);
            };

            TableCell.prototype.getFormulaFunc = function() {
                return this.formulaFunc;
            };
            TableCell.prototype.setFormulaFunc = function(v) {
                this.formulaFunc = v;
            };

            TableCell.prototype.getFormula = function() {
                return this.getTd().getAttribute("formula");
            };
            TableCell.prototype.setFormula = function(v) {
                if (v != null && 
                v.length > 0)
                this.getTd().setAttribute("formula", v);
                else
                this.getTd().removeAttribute("formula");
            }

            var isBarItem = function(el) {
                return el != null && 
                el.className != null && 
                el.className.search(/(^|\\s)spreadsheetBarItem(\\s|$)/) >= 0;
            }

            var isClass = function(el, className) {
                return el != null && 
                el.className != null && 
                el.className.search('(^|\\s)' + className + '(\\s|$)') >= 0;
                // TODO: Might want to cache the regexp.
            }

            var copyNodeTree = function(src, filterFunc, nodeFactory) {
                // Copies ELEMENTS, their attributes, and TEXT nodes.
                if (nodeFactory == null)
                nodeFactory = document;
                var dst = null;
                if (filterFunc == null || 
                filterFunc(src) == true) {
                    if (src.nodeType == 1) {
                        // ELEMENT_NODE
                        dst = nodeFactory.createElement(src.tagName);
                        $(src.attributes).each(function(i) {
                            var val = src.getAttribute(this.name);
                            if (val != null && 
                            val != "")
                            dst.setAttribute(this.name, val);
                        });
                        $(src.childNodes).each(function(i) {
                            var dstChild = copyNodeTree(this, filterFunc, nodeFactory);
                            if (dstChild != null)
                            dst.appendChild(dstChild);

                        });
						
                    } else if (src.nodeType == 3)
                    // TEXT_NODE
                    dst = nodeFactory.createTextNode(src.data);
                }
                return dst;
            }

            var isFirstChild = function(node) {
                while (node.previousSibling != null && 
                node.previousSibling.nodeType != 1)
                node = node.previousSibling;
                return node.previousSibling == null;
            }

            var getParent = function(node, tagName) {
                while (node != null && 
                node.tagName != tagName)
                node = node.parentNode;
                return node;
            }

            var categorizeParents = function(node, parentClasses) {
                while (node != null && node != document.documentElement) {
                    for (var name in parentClasses)
                    if (isClass(node, name)) {
                        parentClasses[name] = node;
                        break;
                    }
                    node = node.parentNode;
                }
            }

            var removeElementById = function(id, doc) {
                if (doc == null)
                doc = document;
                var el = doc.getElementById(id);
                if (el != null)
                el.parentNode.removeChild(el);
            }

            var genId = function(prefix) {
                if (prefix == null)
                prefix = "id";
                return prefix + new Date().getTime() + "-" + theMath.floor(theMath.random() * 1000000);
            }

            var makeBarAdjustor = function(tableBodyId) {
                // Returns an event handler for onscroll and onresize.
                var spreadsheetScrollId = tableBodyId + "_spreadsheetScroll";
                return function() {
                    // The evt is ignored.
                    var spreadsheetScroll = document.getElementById(spreadsheetScrollId);
                    if (spreadsheetScroll != null) {
                        var spreadsheetBarCorner = document.getElementById(tableBodyId + "_spreadsheetBars_spreadsheetBarCorner");
                        var spreadsheetBarLeft = document.getElementById(tableBodyId + "_spreadsheetBars_spreadsheetBarLeft");
                        var spreadsheetBarTop = document.getElementById(tableBodyId + "_spreadsheetBars_spreadsheetBarTop");

                        if (spreadsheetBarTop != null)
                        spreadsheetBarTop.style.top = spreadsheetScroll.scrollTop;
                        if (spreadsheetBarLeft != null)
                        spreadsheetBarLeft.style.left = spreadsheetScroll.scrollLeft;
                        if (spreadsheetBarCorner != null) {
                            spreadsheetBarCorner.style.top = spreadsheetScroll.scrollTop;
                            spreadsheetBarCorner.style.left = spreadsheetScroll.scrollLeft;
                        }
                    }
                }
            }

            jSheet.spreadsheet.toCompactSource = function(node) {
                var result = "";
                if (node.nodeType == 1) {
                    // ELEMENT_NODE
                    if ((node.id != null && node.id.indexOf("spreadsheetBar") >= 0) || 
                    (node.className != null && node.className.indexOf("spreadsheetBar") >= 0))
                    return "";
                    result += "<" + node.tagName;
                    for (var i = 0, hasClass = false; i < node.attributes.length; i++) {
                        var key = node.attributes[i].name;
                        var val = node.getAttribute(key);
                        if (val != null && 
                        val != "") {
                            if (key == "contentEditable" && val == "inherit")
                            continue;
                            // IE hack.
                            if (key == "class") {
                                hasClass = true;
                                val = val.replace("spreadsheetCellActive", "");
                            }
                            if (typeof(val) == "string")
                            result += " " + key + '="' + val.replace(/"/g, "'") + '"';
                            else if (key == "style" && val.cssText != "")
                            result += ' style="' + val.cssText + '"';
                        }
                    }
                    if (node.tagName == "TABLE" && !hasClass)
                    // IE hack, where class doesn't appear in attributes.
                    result += ' class="spreadsheet"';
                    if (node.tagName == "COL")
                    // IE hack, which doesn't like <COL..></COL>.
                    result += '/>';
                    else {
                        result += ">";
                        var childResult = "";
                        $(node.childNodes).each(function() {
                            childResult += jSheet.spreadsheet.toCompactSource(this);
                        });
                        result += childResult;
                        result += "</" + node.tagName + ">";
                    }
					
                } else if (node.nodeType == 3)
                // TEXT_NODE
                result += node.data.replace(/^\s*(.*)\s*$/g, "$1");
                return result;
            }

            jSheet.spreadsheet.toPrettySource = function(node, prefix) {
                if (prefix == null)
                prefix = "";
                var result = "";
                if (node.nodeType == 1) {
                    // ELEMENT_NODE
                    if ((node.id != null && node.id.indexOf("spreadsheetBar") >= 0) || 
                    (node.className != null && node.className.indexOf("spreadsheetBar") >= 0))
                    return "";
                    result += "\n" + prefix + "<" + node.tagName;
                    for (var i = 0; i < node.attributes.length; i++) {
                        var key = node.attributes[i].name;
                        var val = node.getAttribute(key);
                        if (val != null && 
                        val != "") {
                            if (key == "contentEditable" && val == "inherit")
                            continue;
                            // IE hack.
                            if (typeof(val) == "string")
                            result += " " + key + '="' + val.replace(/"/g, "'") + '"';
                            else if (key == "style" && val.cssText != "")
                            result += ' style="' + val.cssText + '"';
                        }
                    }
                    if (node.childNodes.length <= 0)
                    result += "/>";
                    else {
                        result += ">";
                        var childResult = "";
                        for (var i = 0; i < node.childNodes.length; i++)
                        childResult += jSheet.spreadsheet.toPrettySource(node.childNodes[i], prefix + "  ");
                        result += childResult;
                        if (childResult.indexOf('\n') >= 0)
                        result += "\n" + prefix;
                        result += "</" + node.tagName + ">";
                    }

                } else if (node.nodeType == 3)
                // TEXT_NODE
                result += node.data.replace(/^\s*(.*)\s*$/g, "$1");
                return result;
            }

        })();
        $(document).ready(function() {
            jSheet.spreadsheet.initDocument();
        });
		$('#pret').click(function(){
			var s = jSheet.spreadsheet.toPrettySource(document.getElementById('t1'));
	        var w = window.open();
	        w.document.write("<html><body><xmp>" + s + "\n</xmp></body></html>");
	        w.document.close();
	        return false;
		});
		$('#reg').click(function(){
			var s = jSheet.spreadsheet.toCompactSource(document.getElementById('t1'));
	        var w = window.open();
	        w.document.write("<html><body><xmp>" + s + "\n</xmp></body></html>");
	        w.document.close();
	        return false;
		});
    }
});