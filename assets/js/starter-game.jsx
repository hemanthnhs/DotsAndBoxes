import React from 'react';
import ReactDOM from 'react-dom';
import {Stage, Layer, Circle, Line, Rect} from 'react-konva';
import _ from 'lodash';

export default function game_init(root, channel, room_channel, game_name) {
    ReactDOM.render(<Starter channel={channel} room_channel={room_channel} game_name={game_name}/>, root);
}

class Starter extends React.Component {
    constructor(props) {
        super(props);
        this.channel = props.channel
        this.room_channel = props.room_channel
        this.state = {
            lines: [],
            msgs: [],
            game: {
                rows: 0, cols: 0, active_dot: 0, adjacent_dots: [], dots: {}, boxes: [], completed_dots: []
                , scores: {}, game_config: {curr_player: "", players: [], start: false}
            }
        }
        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => {
                console.log("Unable to join", resp);
            });

        this.room_channel
            .join()
            .receive("ok", () => console.log("Connected"))
            .receive("error", resp => {
                console.log("Unable to join", resp);
            });

        this.channel.on("update", this.got_view.bind(this));

        this.room_channel.on("new_message", this.got_msg.bind(this))
    }

    got_view(view) {
        console.log("new view", view.game);
        this.setState({game: view.game});
    }

    got_msg(view) {
        console.log("new view", view.msg);
        this.setState({
            msgs: this.state.msgs.concat(view.msg)
        })
    }

    handleClick(ev, your_turn) {
        this.channel.push("select", {dot_id: ev.target.attrs.id})
            .receive("ok", this.got_view.bind(this), this.handleMove(ev, your_turn));
    }

    handleChatBtnClick() {
        this.room_channel.push("chat", {msg: document.getElementById("input-msg").value})

    }

    handleMove(event, your_turn) {
        if (your_turn) {
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

    getOutlineColor(game, ind) {
        if (game.active_dot == ind) {
            return "white"
        }
        if (game.adjacent_dots.includes(ind)) {
            return "FireBrick"
        }
        return "LightSlateGray"
    }

    getPositionCordinate(id, rows, cols) {
        let row_id = Math.ceil(id / cols);
        let col_id = id - ((row_id - 1) * cols);
        return {row_id, col_id}
    }

    renderCompletedBoxes(boxes, rows, cols, images) {
        // TODO
        let rects = []
        let that = this
        _.forEach(boxes, function (val, key) {
            _(val).each(function (sq_cords) {
                let {row_id, col_id} = that.getPositionCordinate(sq_cords[0], rows, cols)
                //Reference https://konvajs.org/docs/react/Shapes.html
                rects.push(<Rect
                        x={50 * col_id}
                        y={50 * row_id}
                        width={50}
                        height={50}
                        fillPatternImage={images[key]}
                        fillPatternScale={{x: 0.5, y: 0.5}}
                        shadowBlur={10}
                    />
                )
            })
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
                                     stroke="black"
                                     strokeWidth={17}
                                     ref="line"
                    />)
                    lines.push(<Line x={start.row_id} y={start.col_id}
                                     points={[50 * start.col_id
                                         , 50 * start.row_id, 50 * end.col_id, 50 * end.row_id]}
                                     stroke="DarkCyan"
                                     strokeWidth={13}
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
                let lines = []
                lines.push(<Line x={this.state.lines[0]} y={this.state.lines[1]}
                                 points={[50 * this.state.lines[1]
                                     , 50 * this.state.lines[0], this.state.lines[2], this.state.lines[3]]}
                                 stroke="white"
                                 strokeWidth={15}
                                 ref="line"
                />)
                lines.push(<Line x={this.state.lines[0]} y={this.state.lines[1]}
                                 points={[50 * this.state.lines[1]
                                     , 50 * this.state.lines[0], this.state.lines[2], this.state.lines[3]]}
                                 stroke="FireBrick"
                                 strokeWidth={10}
                                 ref="line"
                />)
                return lines;
            } else {
                return (<Line x={this.state.lines[0]} y={this.state.lines[1]}
                              points={[50 * this.state.lines[1]
                                  , 50 * this.state.lines[0], this.state.lines[2], this.state.lines[3]]}
                              dash={[33, 10]}
                              stroke="DarkGray"
                              strokeWidth={15}
                              ref="line"
                />)

            }
        }
    }

    renderBoard(game, your_turn, user_imgs) {
        let m_dots = game.rows;
        let n_dots = game.cols;
        let ind = 1;
        let rows = []
        for (let i = 1; i <= m_dots; i++) {
            for (let j = 1; j <= n_dots; j++) {
                if (_.includes(game.completed_dots, ind)) {
                    rows.push(<Circle className="circle" radius={17} x={50 * j} y={50 * i}
                                      fill="black" id={ind}
                    />)
                } else {
                    rows.push(<Circle className="circle" radius={17} x={50 * j} y={50 * i}
                                      fill={this.getFillColor(game, ind)}
                                      id={ind} onClick={(e) => this.handleClick(e, your_turn)}
                                      shadowColor="black"
                                      shadowBlur={5}
                                      shadowOpacity={0.7}
                                      stroke={this.getOutlineColor(game, ind)}
                                      strokeWidth={2}
                    />)
                }
                ind++
            }
        }
        let images = []
        _.each([...Array(4).keys()], function (key) {
            let image = new Image()
            image.src = user_imgs[key]
            images.push(image)
        })
        return (
            <div className="board">
                <Stage className="offset-3" onMouseMove={(e) => this.handleMove(e, your_turn)} width={512} height={452}>
                    <Layer>
                        {this.renderCompletedBoxes(game.boxes, game.rows, game.cols, images)}
                        {this.renderConnectedLines(game.dots, game.rows, game.cols)}
                        {this.renderConnnectingLine()}
                        {rows}
                    </Layer>
                </Stage>
            </div>);
    }

    renderStatus(game, your_turn, user_imgs) {
        let score_lists = []
        _.each(this.state.game.game_config.players, function (e, ind) {
            score_lists.push(<li key={ind + 1}><img className={"score-icons"} src={user_imgs[ind + 1]}/>{e} :
                {game.scores[ind + 1]}</li>)
        })
        return (<div className="status card-group">
            <div className="scores col-8">
                {/*<div className="font-weight-bold"><u>Scores</u></div>*/}
                <ul>{score_lists}</ul>
            </div>
            <div className={"col-4 h3 " + ((your_turn) ? "turn-display-active" : "turn-display")}>
                {(your_turn) ? "Your turn!!!" : "Waiting for " + this.state.game.game_config.curr_player}
            </div>
        </div>)
    }

    formatChatMsgs() {
        let msgs = []
        _(this.state.msgs).each(function (msg) {
            msgs.push(<span className="offset-1 row msg">{msg}</span>)
        })
        return msgs
    }

    renderChatArea(player_name) {
        return (
            <div className="chat-container">
                <div className="chat-msgs ow-break-word">{this.formatChatMsgs()}</div>
                <div className="form-group row msg-input">
                    <input type="text" id="input-msg" className="form-control offset-1 col-8"/>
                    <button className="btn btn-primary" onClick={() => this.handleChatBtnClick()}>Submit</button>
                </div>
            </div>
        )
    }

    render() {
        //Attribution : https://getbootstrap.com/docs/4.3/components/navbar/
        let game = this.state.game
        let player_name = this.channel.socket.params().player_name
        let your_turn = (this.state.game.game_config.curr_player == player_name)
        let user_imgs = {
            1: window.img_paths[0],
            2: window.img_paths[1],
            3: window.img_paths[2],
            4: window.img_paths[3]
        }
        let gameStarted = <div className="offset-1 col-6 container">
            {this.renderBoard(game, your_turn, user_imgs)}
            {this.renderStatus(game, your_turn, user_imgs)}
        </div>
        let waitingScreen = <div className="offset-1 col-6 waiting-board">Please wait till players are connected</div>
        return (<div>
            <nav className="navbar navbar-dark bg-primary">
                <span className="navbar-brand mb-0 h1">DOTS AND BOXES</span>
                <span className="navbar-text">
                  Game name : {this.props.game_name}
                    <br/>
                    {_.includes(this.state.game.game_config.players, player_name)
                        ? "Playing as " + player_name : "Spectating as " + player_name}
                </span>
            </nav>
            <br/>
            <div className="row">
                {this.state.game.game_config.start ? gameStarted : waitingScreen}
                <div className="col-3 container">
                    {this.renderChatArea(player_name)}
                </div>
            </div>
        </div>)
    }
}