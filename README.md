Docker container that come preinstalled with Debian 8, Python 2.7, jupyter notebook and key scientific Python packages.

## Usage

* You can pull the container by running `sudo docker pull ghislainv/docker-debian-jupyter`.
* Run `sudo docker run -d -p 8888:8888 -v ORIGIN_FOLDER:/home/jrc/notebooks ghislainv/docker-debian-jupyter`
    * Replace `ORIGIN_FOLDER` with a folder on your local machine that you want to persist notebooks in.
* Open your browser and start working with Jupyter notebook.
    * On Linux, the url will be `localhost:8888`.
    * On Windows/OSX, run `docker-machine ip default` (replace `default` with the name of your machine). Then, you'll be able to access Jupyter notebook at `CONTAINER_IP:8888`.
