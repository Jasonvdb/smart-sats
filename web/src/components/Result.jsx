import React, { useState } from "react";
import Nav from 'react-bootstrap/Nav';

const Result = ({html}) => {
    const [tab, setTab] = useState("code");

    return (
        <>
            <Nav variant="pills" defaultActiveKey="/home" activeKey={tab} onSelect={setTab} style={{marginBottom: 20}}>
                <Nav.Item>
                    <Nav.Link eventKey="code">Code</Nav.Link>
                </Nav.Item>
                <Nav.Item>
                    <Nav.Link eventKey="result">Result</Nav.Link>
                </Nav.Item>
            </Nav>

            {tab === "code" ? <>
                <div style={{ flex: 1, backgroundColor: 'black', padding: 10, width: '100%', minHeight: 600}}>
                    <pre style={{fontSize: 8, color: 'green'}}>{html}</pre>
                </div>
                </> : <span/>
            }

            {tab === "result" ? <>
                <iframe style={{width: '100%', height: 700}} srcDoc={html} />
                </> : <span/>
            }
        </>
    );
}

export default Result
