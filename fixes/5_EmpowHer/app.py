import os
import time
from collections import defaultdict, deque

from flask import Flask, render_template, request, jsonify
import google.generativeai as genai

app = Flask(__name__)

# The Gemini key is read from the environment, never written in the code.
# On Render: Dashboard -> this service -> Environment -> add GEMINI_API_KEY.
# The key that used to be on this line is public in the git history, so it
# must be revoked in Google AI Studio and replaced with a new one, not reused.
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel("gemini-2.0-flash")
else:
    model = None

# Every AI route below is open to anyone on the internet, so each one is
# capped: a prompt length limit, and a per-address limit per hour. Without
# these, anyone can run up the bill on the key.
MAX_PROMPT_CHARS = 2000
MAX_CALLS_PER_HOUR = 20
_calls = defaultdict(deque)


def _blocked(prompt):
    """Returns a message if this request should not reach Gemini, else None."""
    if model is None:
        return "The AI assistant is not configured on this server."
    if len(prompt) > MAX_PROMPT_CHARS:
        return f"Please keep the message under {MAX_PROMPT_CHARS} characters."
    ip = (request.headers.get("X-Forwarded-For") or request.remote_addr or "?").split(",")[0].strip()
    now = time.time()
    q = _calls[ip]
    while q and now - q[0] > 3600:
        q.popleft()
    if len(q) >= MAX_CALLS_PER_HOUR:
        return "Too many requests. Please try again in a while."
    q.append(now)
    return None

# ------------------------- AI ROUTES -------------------------

# AI Assistant Route (used for abuse reporting and legal right advisor)
@app.route('/ai_assistant', methods=['POST'])
def ai_assistant():
    data = request.get_json(silent=True) or {}
    user_input = data.get("prompt", "")

    if not user_input:
        return jsonify({"response": "Please enter a message for the AI assistant."})

    blocked = _blocked(user_input)
    if blocked:
        return jsonify({"response": blocked})

    try:
        response = model.generate_content(user_input)
        cleaned_text = response.text.strip().replace("*", "").replace("-", "").replace("\n\n", "\n")
        return jsonify({"response": cleaned_text})
    except Exception as e:
        app.logger.exception("Gemini call failed")
        return jsonify({"response": "Sorry, the assistant could not answer right now. Please try again later."})

# AI-based Startup Idea Generator
@app.route('/generate-idea', methods=['POST'])
def generate_idea():
    data = request.get_json(silent=True) or {}
    user_prompt = data.get("prompt", "")
    prompt = f"Suggest some innovative small-scale or home-based business ideas for women based on the following interests: {user_prompt}. Keep them practical and inspiring."

    blocked = _blocked(user_prompt)
    if blocked:
        return jsonify({"idea": blocked})

    try:
        response = model.generate_content(prompt)
        idea_text = response.text.strip()
        return jsonify({"idea": idea_text})
    except Exception as e:
        return jsonify({"idea": "Sorry, I couldn't generate an idea at the moment. Please try again later."})

# AI Mentor Route
@app.route('/ai_mentor', methods=['POST'])
def ai_mentor():
    data = request.get_json(silent=True) or {}
    prompt = data.get("prompt", "")

    if not prompt:
        return jsonify({"response": "No input provided."})

    blocked = _blocked(prompt)
    if blocked:
        return jsonify({"response": blocked})

    try:
        response = model.generate_content(prompt)
        raw_text = response.text.strip()

        cleaned_text = raw_text.replace("*", "").replace("-", "").replace("\n\n", "\n").strip()
        lines = cleaned_text.split('\n')
        spaced_lines = [line.strip() + "\n" for line in lines if line.strip()]
        limited_text = '\n\n'.join(spaced_lines[:15])

        return jsonify({"response": limited_text})
    except Exception as e:
        app.logger.exception("Gemini call failed")
        return jsonify({"response": "Sorry, the assistant could not answer right now. Please try again later."})


# ------------------------- PAGE ROUTES -------------------------

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/skill_building', methods=['GET', 'POST'])
def skill_building():
    response = None
    if request.method == 'POST':
        interest = request.form.get("interest", "")
        if interest:
            prompt = f"""
You are a course recommendation assistant for women's empowerment. A user is interested in "{interest}".
Suggest 5 to 10 beginner-friendly online courses or platforms that are easy to start and accessible.
Format your response as a numbered list with course title and platform.
Only include relevant, readable suggestions without explanations or URLs.
"""
            blocked = _blocked(interest)
            if blocked:
                return render_template("skill_building.html", response=blocked)
            try:
                result = model.generate_content(prompt)
                response = result.text
            except Exception:
                app.logger.exception("Gemini call failed")
                response = "Sorry, there was an error while fetching suggestions."
    return render_template("skill_building.html", response=response)

@app.route('/abuse_reporting')
def abuse_reporting():
    return render_template('abuse_reporting.html')

@app.route('/mentorship')
def mentorship():
    return render_template('mentorship.html')

@app.route('/legal_rights')
def legal_rights():
    return render_template('legal_rights.html')

@app.route('/wage_gap')
def wage_gap():
    return render_template('wage_gap.html')

@app.route('/leadership')
def leadership():
    return render_template('leadership.html')

@app.route('/blogs')
def blogs():
    return render_template('blogs.html')

@app.route('/feedback')
def feedback():
    return render_template('feedback.html')

@app.route('/wellness')
def wellness():
    return render_template('wellness.html')

@app.route('/businesses')
def businesses():
    return render_template('businesses.html')


# ------------------------- MAIN -------------------------

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
