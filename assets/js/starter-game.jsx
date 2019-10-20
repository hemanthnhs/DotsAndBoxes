import React from 'react';
import ReactDOM from 'react-dom';
import {Stage, Layer, Circle, Line, Rect} from 'react-konva';
import _ from 'lodash';

export default function game_init(root, channel) {
    ReactDOM.render(<Starter channel={channel}/>, root);
}

class Starter extends React.Component {
    constructor(props) {
        super(props);
        this.channel = props.channel
        this.state = {
            lines: [],
            completed_lines: [],
            game: {rows: 0, cols: 0, active_dot: 0, adjacent_dots: [], dots: {}, boxes: [], completed_dots: []}
        }
        this.handleClick = this.handleClick.bind(this)
        this.handleMove = this.handleMove.bind(this)
        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => {
                console.log("Unable to join", resp);
            });
        this.channel.on("update", this.got_view.bind(this));
    }

    got_view(view) {
        console.log("new view", view.game);
        this.setState({game: view.game});
    }

    handleClick(ev) {
        console.log(ev.target.attrs);
        this.channel.push("select", {dot_id: ev.target.attrs.id})
            .receive("ok", this.got_view.bind(this), this.handleMove(ev));
    }

    handleMove(event) {
        if (event.type == "click") {
            // Condition 1 - line is being drawn now
            // Condition 2 - line is being ended now
            if (this.state.lines.length == 0) {
                let x = event.target.attrs.x
                let y = event.target.attrs.y
                this.setState({lines: [y / 50, x / 50]})
            } else {
                //stop the line and move to completed lines
                if (_.includes(this.state.game.adjacent_dots, event.target.attrs.id) || this.state.game.active_dot == event.target.attrs.id) {
                    this.setState({lines: []})
                }
            }
        } else {
            //on mouse move
            if (this.state.lines.length != 0) {
                let lines = this.state.lines
                let x2 = event.evt.layerX
                let y2 = event.evt.layerY
                this.setState({lines: [lines[0], lines[1], x2, y2]})
            }
        }
    }

    getFillColor(game, ind) {
        if (game.active_dot == ind) {
            return "BurlyWood"
        }
        if (game.adjacent_dots.includes(ind)) {
            return "DarkSeaGreen"
        }
        return "black"
    }

    getPositionCordinate(id, rows, cols) {
        let row_id = Math.ceil(id / cols);
        let col_id = id - ((row_id - 1) * cols);
        return {row_id, col_id}
    }

    renderCompletedBoxes(boxes, rows, cols) {
        let rects = []
        let that = this
        _(boxes).each(function (sq_cords) {
            let {row_id, col_id} = that.getPositionCordinate(sq_cords[0], rows, cols)
            rects.push(<Rect
                    x={50 * col_id}
                    y={50 * row_id}
                    width={50}
                    height={50}
                    fill="brown"
                    shadowBlur={10}
                />
            )
        })
        return rects;
    }

    renderConnectedLines(connected_dots, rows, cols) {
        let lines = []
        let that = this
        _.forEach(connected_dots, function (val, start_cord) {
            _(val).each(function (end_cord) {
                if (start_cord < end_cord) {
                    let start = that.getPositionCordinate(start_cord, rows, cols)
                    let end = that.getPositionCordinate(end_cord, rows, cols)
                    lines.push(<Line x={start.row_id} y={start.col_id}
                                     points={[50 * start.col_id
                                         , 50 * start.row_id, 50 * end.col_id, 50 * end.row_id]}
                                     stroke="DarkCyan"
                                     strokeWidth={20}
                                     ref="line"
                    />)
                }
            });
        });
        return lines;
    }

    renderConnnectingLine() {
        if (this.state.lines.length > 0) {
            if (Math.abs((50 * this.state.lines[1]) - this.state.lines[2]) < 67
                && Math.abs((50 * this.state.lines[0]) - this.state.lines[3]) < 67) {
                return (<Line x={this.state.lines[0]} y={this.state.lines[1]}
                              points={[50 * this.state.lines[1]
                                  , 50 * this.state.lines[0], this.state.lines[2], this.state.lines[3]]}
                              stroke="FireBrick"
                              strokeWidth={20}
                              ref="line"
                />)
            } else {
                return (<Line x={this.state.lines[0]} y={this.state.lines[1]}
                              points={[50 * this.state.lines[1]
                                  , 50 * this.state.lines[0], this.state.lines[2], this.state.lines[3]]}
                              dash={[33, 10]}
                              stroke="DarkGray"
                              strokeWidth={20}
                              ref="line"
                />)

            }
        }
    }

    renderBoard(game) {
        let m_dots = game.rows;
        let n_dots = game.cols;
        let ind = 1;
        let rows = []
        for (let i = 1; i <= m_dots; i++) {
            for (let j = 1; j <= n_dots; j++) {
                if (_.includes(game.completed_dots, ind)) {
                    rows.push(<Circle className="circle" radius={17} x={50 * j} y={50 * i}
                                      fill="DarkSlateGray" id={ind}
                    />)
                } else {
                    rows.push(<Circle className="circle" radius={17} x={50 * j} y={50 * i}
                                      fill={this.getFillColor(game, ind)}
                                      id={ind} onClick={this.handleClick} shadowColor="black" shadowBlur={5}
                                      shadowOpacity={0.7}
                    />)
                }
                ind++
            }
        }
        return (
            <div className="board">
                <Stage className="offset-3" onMouseMove={this.handleMove} width={512} height={512}>
                    <Layer>
                        {this.renderCompletedBoxes(game.boxes, game.rows, game.cols)}
                        {this.renderConnectedLines(game.dots, game.rows, game.cols)}
                        {this.renderConnnectingLine()}
                        {rows}
                    </Layer>
                </Stage>
            </div>);
    }

    render() {
        //Attribution : https://getbootstrap.com/docs/4.3/components/navbar/
        let game = this.state.game
        return (<div>
            <nav className="navbar navbar-dark bg-primary">
                <span className="navbar-brand mb-0 h1">DOTS AND BOXES</span>
                <span className="navbar-text">
                  Game id : 29
                </span>
            </nav>
            <br/>
            <div className="offset-1 col-6 container">
                {this.renderBoard(game)}
            </div>

        </div>)
    }
}