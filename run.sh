docker run -ti -p 4000:4000 -v $(pwd)/src/main:/che-docs:Z rkratky/jekyll-docs sh -c "cd /che-docs; mkdir -p _site; chown jekyll:jekyll _site; jekyll serve"

