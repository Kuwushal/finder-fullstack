import { useState, useRef, useEffect } from "react"
import "./App.css"

const API = "http://localhost:8000"

export default function App() {
  const [messages, setMessages] = useState([
    { role: "remember", text: "Hey. Tell me where you put something, or ask me where it is." }
  ])
  const [input, setInput] = useState("")
  const [loading, setLoading] = useState(false)
  const bottomRef = useRef(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" })
  }, [messages])

  async function send() {
    const text = input.trim()
    if (!text || loading) return

    setMessages(prev => [...prev, { role: "user", text }])
    setInput("")
    setLoading(true)

    try {
      const res = await fetch(`${API}/ai/chat`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: text })
      })
      const data = await res.json()
      setMessages(prev => [...prev, { role: "remember", text: data.message || data.detail }])
    } catch {
      setMessages(prev => [...prev, { role: "remember", text: "Could not reach the server." }])
    } finally {
      setLoading(false)
    }
  }

  function handleKey(e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault()
      send()
    }
  }

  return (
    <div className="app">
      <header>
        <span className="logo">⬡</span>
        <h1>Remember</h1>
        <p>remembers where you put things</p>
      </header>

      <div className="chat">
        {messages.map((m, i) => (
          <div key={i} className={`bubble ${m.role}`}>
            {m.role === "remember" && <span className="tag">remember</span>}
            <p>{m.text}</p>
          </div>
        ))}
        {loading && (
          <div className="bubble remember">
            <span className="tag">remember</span>
            <p className="thinking"><span /><span /><span /></p>
          </div>
        )}
        <div ref={bottomRef} />
      </div>

      <div className="input-row">
        <input
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={handleKey}
          placeholder="I put my keys in the desk drawer..."
          disabled={loading}
          autoFocus
        />
        <button onClick={send} disabled={loading || !input.trim()}>
          →
        </button>
      </div>
    </div>
  )
}
