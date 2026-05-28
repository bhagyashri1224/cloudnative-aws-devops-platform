from app import app


def test_home():
    app.config['TESTING'] = True
    client = app.test_client()

    response = client.get('/')

    assert response.status_code == 200
    assert b'hostname' in response.data or b'Hello' in response.data
