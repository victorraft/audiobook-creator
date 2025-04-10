"""
Audiobook Creator
Copyright (C) 2025 Prakhar Sharma

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""

import traceback

def check_if_kokoro_api_is_up(client):
    try:
        with client.audio.speech.with_streaming_response.create(
            model="kokoro",
            voice="af_heart",
            response_format="aac",  # Ensuring format consistency
            speed=0.85,
            input="Hello, how are you ?"
        ) as response:
            return True, None
    except Exception as e:
        traceback.print_exc()
        return False, "The Kokoro API is not working. Please check if the .env file is correctly set up and the Kokoro API is up. Error: " + str(e)