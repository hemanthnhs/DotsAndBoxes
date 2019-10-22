import React from 'react';

// Attribution: https://github.com/hemanthnhs/interview-demos/blob/master/src/components/Input.jsx
const ChatInputComp = (props) => {
    return (
        <div className="form-group row">
            <input type="text" id="input-msg"
                   className="form-control offset-1 col-8" value={props.value} onChange={props.onInputChange}/>
            <button className="btn btn-primary" onClick={props.onBtnClick}>Submit</button>
        </div>
    )
}

export default ChatInputComp;