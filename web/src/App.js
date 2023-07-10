import React, { useEffect, useState } from "react";
import io from 'socket.io-client';

const socket = io('http://192.168.1.108:3210', {
  auth: {
    token: 'your-auth-token' //TODO
  }
});

var loaded = false;

const App = () => {
  const [prompt, setPrompt] = useState("A website about Bitcoin.\n" +
  "Add a section must be a list of the benefits.\n" +
  "Add a section with possible ways to use it.\n" +
  "Make a note somewhere about the lightning network and how amazing it is.\n");
  const [response, setResponse] = useState("");
  const [status, setStatus] = useState("");
  const [isReady, setIsReady] = useState(false);
  const [progressUpdates, setProgressUpdates] = useState([]);

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
    setResponse('');
    setIsReady(false);
    setProgressUpdates([]);
    socket.emit('prompt', prompt);
  };

  return (
    <div style={{padding: 20}}>
      <h1>Web Dev Agent (Smart Sats Demo)</h1>
      <h2>Status: {status}</h2>
      <textarea style={{height: 200, width: 600}} value={prompt} onChange={handlePromptChange} />
      <button disabled={!isReady} onClick={handlePromptSubmit}>Submit</button>

      <ul>
        {progressUpdates.map((item) => {
          return <li style={{fontSize: 10}}>{item}</li>
        })}
      </ul>
      <br/><br/><br/><br/>

      <div style={{ display: 'flex', flexDirection: 'row', width: '100%' }}>
        <div style={{ flex: 1, backgroundColor: '#ddd', padding: 10, width: 600, minHeight: 600}}>
          <pre style={{fontSize: 8}}>{response}</pre>
        </div>

        <div style={{ flex: 1, backgroundColor: '#eee' }}>
          <iframe style={{width: 600, height: 700}} srcDoc={response} />
        </div>
      </div>  
    </div>
  );
};

export default App;