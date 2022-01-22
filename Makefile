clean_web:
	rm -rf build/web
	rm -rf docs

build_web: clean_web
	flutter build web --web-renderer canvaskit --base-href "/flutter_stories/"
	mkdir docs
	mv build/web/* docs/
