from app import app


def test_home():
    app.config['TESTING'] = True
    client = app.test_client()

    response = client.get('/')

    assert response.status_code == 200
    assert b'Hostname' in response.data
    assert b'CloudNative AWS DevOps Platform' in response.data
