
upload:
	# docker images
	# docker login
	docker build -t tsangpo/coder .
	docker push tsangpo/coder
