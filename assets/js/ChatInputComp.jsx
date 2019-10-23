import React from 'react';

// Attribution: https://github.com/hemanthnhs/interview-demos/blob/master/src/components/Input.jsx
const ChatInputComp = (props) => {
    return (
        <div className="form-group row col-12">
            <input type="text" id="input-msg"
                   className="form-control offset-1 col-8" value={props.value} onChange={props.onInputChange}/>
            <button className="col-3 btn btn-primary" onClick={props.onBtnClick} disabled={props.value.length == 0}>Submit</button>
        </div>
    )
}

export default ChatInputComp;