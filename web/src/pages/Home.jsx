import React, { useEffect, useState } from "react";
import io from 'socket.io-client';
import Button from 'react-bootstrap/Button';
import Toast from 'react-bootstrap/Toast';
import Authentication from '../components/Authentication';
import NavBar from "../components/Navbar";
import Container from "react-bootstrap/Container";
import ListGroup from 'react-bootstrap/ListGroup';
import Result from "../components/Result";

const socket = io('https://cheapwebdev.intern.cheap', {
    auth: {
        token: 'your-auth-token' //TODO
    }
});

let loaded = false;

const Home = () => {
    const [authToken, setAuthToken] = useState("");

    const [prompt, setPrompt] = useState("A website about Bitcoin.\n" +
        "Add a section must be a list of the benefits.\n" +
        "Add a section with possible ways to use it.\n" +
        "Make a note somewhere about what the lightning network is and how amazing it is.\n");
    const [response, setResponse] = useState("");
    const [status, setStatus] = useState("");
    const [isReady, setIsReady] = useState(false);
    const [progressUpdates, setProgressUpdates] = useState([]);
    const [latestProgressUpdate, setLatestProgressUpdate] = useState("");

    useEffect(() => {
        if (loaded) return;

        socket.on('code_response', (data) => {
            if (data == '[DONE]') {
                setStatus("App ready! 🎉")
                setIsReady(true);
                setResponse((prevData) => prevData.replaceAll("\`\`\`html", ""));
                setResponse((prevData) => prevData.replaceAll("\`\`\`", ""));
                return;
            }

            if (data == '[ERROR]') {
                setStatus("Error! ❌");
                setIsReady(true);
                return;
            }

            setStatus("Coding... ⏳");
            setIsReady(false);

            setResponse((prevData) => prevData.replaceAll("\`\`\`html", ""));
            setResponse((prevData) => prevData + data);
        });

        socket.on('connect', () => {
            setStatus('Ready to code! 🤓');
            setIsReady(true);
        });

        socket.on('disconnect', () => {
            setStatus('Disconnected ❌');
            setIsReady(false);
        });

        socket.on('progress_response', (data) => {
            console.log(data);
            setProgressUpdates((prevData) => [...prevData, data]);
            setLatestProgressUpdate(data);
        });

        socket.on('complete_code' , (data) => {
            setResponse(data);
        });

        loaded = true;
    }, []);

    const handlePromptChange = (event) => {
        setPrompt(event.target.value);
    };

    const handlePromptSubmit = async () => {
        // setLatestProgressUpdate("Test");
        // return;

        setResponse('');
        setStatus("Requesting... ⏳");
        setIsReady(false);
        setProgressUpdates([]);
        socket.emit('prompt', {prompt, token: authToken});
    };

    const auth = <Authentication socket={socket} onAuthenticated={setAuthToken} />;

    return (
        <>
            <NavBar/>
            <Container>
                <Toast
                    onClose={() => setLatestProgressUpdate("")}
                    show={latestProgressUpdate != ""}
                    delay={5000}
                    autohide
                    style={{top: 20, right: 20, position: 'fixed', zIndex: 9999}}
                >
                    <Toast.Header>
                        <span>🤖</span>
                        <strong className="me-auto">Agent progress</strong>
                    </Toast.Header>
                    <Toast.Body>{latestProgressUpdate}</Toast.Body>
                </Toast>
                <p style={{marginTop: 20}}>The cheapest web developer you will ever find. Guaranteed to get your sats worth. (Smart Sats Demo)</p>
                <h2 style={{marginTop: 20}}>Status: {status}</h2>

                <textarea style={{height: 200, width: '100%'}} value={prompt} onChange={handlePromptChange} />
                <Button disabled={!isReady} onClick={handlePromptSubmit}>Submit</Button>

                <ListGroup as="ul" numbered style={{marginTop: 40, marginBottom: 40}}>
                    {progressUpdates.map((item, index) => {
                        return <ListGroup.Item key={item} as="li" active={progressUpdates.length == index + 1} style={{fontSize: 12}}>{item}</ListGroup.Item>
                    })}
                </ListGroup>

                {response && <Result html={response} />}

                {/*<div style={{ display: 'flex', flexDirection: 'row', width: '100%' }}>*/}
                    {/*<div style={{ flex: 1, backgroundColor: '#ddd', padding: 10, width: 600, minHeight: 600}}>*/}
                    {/*    <pre style={{fontSize: 8}}>{response}</pre>*/}
                    {/*</div>*/}


                {/*    <div style={{ flex: 1, backgroundColor: '#eee' }}>*/}
                {/*        <iframe style={{width: 600, height: 700}} srcDoc={response} />*/}
                {/*    </div>*/}
                {/*</div>*/}


                <pre style={{marginTop: 300}}>User: {authToken}</pre>
                {auth}
            </Container>
        </>
    );
};

export default Home;
