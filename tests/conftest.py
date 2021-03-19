import pytest


@pytest.fixture
def refapp():
    app = {
        'start_version': '6',
        'end_version': None,
        'concurrent_builds': '4',
        'default_release': True,
        'docker_repos': ['atlassian/bitbucket-server'],
        'dockerfile': None,
        'dockerfile_buildargs': None,
        'dockerfile_version_arg': 'BITBUCKET_VERSION',
        'mac_product_key': 'bitbucket',
        'tag_suffixes': 'jdk8,ubuntu'.split(','),
        'push_docker': True,
        'test_script': None,
    }
    return app
