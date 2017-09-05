let project = new Project('TilemapScrolling');
project.addAssets('res/**', {
	nameBaseDir: 'res',
	destination: '{dir}/{name}',
	name: '{dir}/{name}'
});
project.addSources('src');
project.addDefine('debug');
project.addParameter('-dce full');

resolve(project);
