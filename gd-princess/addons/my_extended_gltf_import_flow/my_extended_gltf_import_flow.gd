@tool
extends EditorPlugin

var extension: GLTFDocumentExtension;

func _enter_tree() -> void:
	extension = MyGLTFDocumentExtension.new();
	GLTFDocument.register_gltf_document_extension(extension);

func _exit_tree() -> void:
	GLTFDocument.unregister_gltf_document_extension(extension);
	extension = null;
