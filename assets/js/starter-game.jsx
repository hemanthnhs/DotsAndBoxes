import React from 'react';
import ReactDOM from 'react-dom';
import {Stage, Layer, Circle, Line} from 'react-konva';
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
            game: {rows: 0, cols: 0, active_dot: 0, adjacent_dots: [], dots: {}}
        }
        this.handleClick = this.handleClick.bind(this)
        this.handleMove = this.handleMove.bind(this)
        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => {
                console.log("Unable to join", resp);
            });

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

    drawLine(i, j, x2, y2) {
        let constructedLine = [i, j, x2, y2]
        this.setState({lines: constructedLine})

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
                if (_.includes(this.state.game.adjacent_dots, event.target.attrs.id)) {
                    let lines = this.state.lines
                    let completed = this.state.completed_lines
                    console.log("compl", lines[0], lines[1], event.target.attrs.x, event.target.attrs.y)
                    completed.push([lines[0], lines[1], event.target.attrs.x, event.target.attrs.y])
                    this.setState({lines: [], completed: completed})
                } else {
                    //invalid have some ui showing user its invalid
                }
            }
        } else {
            //on mouse move
            if (this.state.lines.length != 0) {
                let lines = this.state.lines
                let x2 = event.evt.screenX - 15
                let y2 = event.evt.screenY - 175
                this.drawLine(lines[0], lines[1], x2, y2)
            }
        }
    }

    getFillColor(game, ind) {
        if (game.active_dot == ind) {
            return "green"
        }
        if (game.adjacent_dots.includes(ind)) {
            return "blue"
        }
        return "black"
    }

    renderBoard(game) {
        let m_dots = game.rows;
        let n_dots = game.cols;
        let fromServer = {1: (2), 2: {}, 3: {}, 4: {}}
        let ind = 1;
        let rows = []
        let constructedLine = []
        for (let i = 1; i <= m_dots; i++) {
            for (let j = 1; j <= n_dots; j++) {

                rows.push(<Circle radius={15} x={50 * j} y={50 * i} fill={this.getFillColor(game, ind)}
                                  id={ind} onClick={this.handleClick}
                />)

                ind++
            }

        }

        if (this.state.lines.length > 0) {
            constructedLine.push(<Line x={this.state.lines[0]} y={this.state.lines[1]}
                                       points={[50 * this.state.lines[1]
                                           , 50 * this.state.lines[0], this.state.lines[2], this.state.lines[3]]}
                                       stroke="red"
                                       strokeWidth={20}
                                       ref="line"
            />)
        }
        let completed_lines = []
        _(this.state.completed_lines).each(function (cl) {
            completed_lines.push(<Line x={cl[0]} y={cl[1]}
                                       points={[50 * cl[1]
                                           , 50 * cl[0], cl[2], cl[3]]}
                                       stroke="green"
                                       strokeWidth={20}
                                       ref="line"
            />)
        })
        return (

            <Stage onMouseMove={this.handleMove} width={512} height={389}>
                <Layer>
                    {completed_lines}
                    {constructedLine}
                    {rows}
                </Layer>
            </Stage>);
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
            <div className="col-10">
                {this.renderBoard(game)}

            </div>

        </div>)
    }
}
