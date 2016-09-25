import os

from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))
with open(os.path.join(here, 'README.md')) as f:
    README = f.read()
with open(os.path.join(here, 'CHANGES.txt')) as f:
    CHANGES = f.read()

requires = [
    'celery',
    'hypothesis',
    'pymongo',
    'pyramid',
    'pyramid_chameleon',
    'pyramid_debugtoolbar',
    'python_levenshtein',
    'waitress',
    'WebTest >= 1.3.1',  # py3 compat
    'pytest',  # includes virtualenv
    'pytest-cov',
    ]

setup(name='decktape_io',
      version='0.0',
      description='decktape_io',
      long_description=README + '\n\n' + CHANGES,
      classifiers=[
          "Programming Language :: Elm",
          "Programming Language :: Python",
          "Programming Language :: Python :: 3.5",
          "Framework :: Pyramid",
          "Topic :: Internet :: WWW/HTTP",
          "Topic :: Internet :: WWW/HTTP :: WSGI :: Application",
      ],
      author='',
      author_email='',
      url='',
      keywords='web pyramid pylons',
      packages=find_packages(),
      include_package_data=True,
      zip_safe=False,
      install_requires=requires,
      entry_points="""\
      [paste.app_factory]
      main = decktape_io:main
      """,
      )
