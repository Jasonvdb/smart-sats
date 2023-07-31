import React, { useEffect, useState } from "react";
import QRCode from "react-qr-code";
import Button from 'react-bootstrap/Button';
import Modal from 'react-bootstrap/Modal';

let loaded = false;

const Authentication = ({socket, onAuthenticated}) => {
    const [qrContent, setQrContent] = useState("");
    const [isAuthenticated, setIsAuthenticated] = useState(null);
    //On first load
    useEffect(() => {
        if (loaded) return;

        onAuthenticated("");

        //Check local storage for token
        const token = localStorage.getItem("token");

        socket.emit('check_auth_status', token);

        socket.on('authenticated', (data) => {
            console.log(data);
            const {token, authenticated, qr} = data;
            setIsAuthenticated(authenticated);

            localStorage.setItem("token", token);

            if (authenticated) {
                onAuthenticated(token);
            } else {
                setQrContent(qr);
            }
        });

        loaded = true;
    });

    if (isAuthenticated === null) return (<div>Authenticated: {isAuthenticated ? "Yes" : "No"}</div>);

    if (isAuthenticated) {
        return <pre>Authenticated!</pre>;
    }

    return (
        <Modal show={!isAuthenticated} style={{textAlign: 'center'}}>
            <Modal.Header>
                <Modal.Title>Scan this with the Smart Sats app to authorize agent</Modal.Title>
            </Modal.Header>
            <Modal.Body >
                <QRCode value={qrContent} />
                <p style={{padding: 20}}>

                </p>
            </Modal.Body>
            <Modal.Footer>
                <a href={"https://testflight.apple.com/join/U4Zqn7Ae"} target="_blank" rel="noreferrer">
                    <Button variant={'warning'}>Download app</Button>
                </a>

                <a href={qrContent} target="_blank" rel="noreferrer">
                    <Button>Open in app</Button>
                </a>

                <p>If you have authorized in the app and still see this try refresh the page</p>
            </Modal.Footer>
        </Modal>
    );
}

export default Authentication
