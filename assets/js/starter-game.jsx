import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
    ReactDOM.render(<Starter channel={channel}/>, root);
}

class Starter extends React.Component {
    constructor(props) {
        super(props);
        this.channel = props.channel
        this.state = {game: {rows: 0, cols: 0, active_dot: 0, adjacent_dots: [], dots: {}}}
        this.handleClick = this.handleClick.bind(this)
        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => {
                console.log("Unable to join", resp);
            });
    }

    got_view(view) {
        console.log("new view", view.game.adjacent_dots);
        this.setState({game: view.game});
    }

    handleClick(ev) {
        let s = this.state.game;
        s.active_dot = ev.target.id;
        this.channel.push("select", {dot_id: ev.target.id})
            .receive("ok", this.got_view.bind(this));
        this.setState({game: s})
    }

    renderBoard(game) {
        let m_dots = game.rows;
        let n_dots = game.cols;
        let fromServer = {1: (2), 2: {}, 3: {}, 4: {}}
        let ind = 0;
        let rows = []
        for (let i = 1; i <= m_dots; i++) {
            let cols = []
            for (let j = 1; j <= n_dots; j++) {
                ind++
                cols.push(<span
                    className={"dot" + ((game.active_dot == ind) ? " dot-active" : "") + (game.adjacent_dots.includes(ind) ? " dot-next" : "")}
                    id={ind} onClick={this.handleClick}></span>)
            }
            rows.push(<div className="col-8">{cols}</div>)
        }
        return rows;
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

