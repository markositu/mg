#include <vector>
#include "skybox.h"
#include "tools.h"
#include "vector3.h"
#include "trfm3D.h"
#include "renderState.h"
#include "gObjectManager.h"
#include "nodeManager.h"
#include "textureManager.h"
#include "materialManager.h"
#include "shaderManager.h"


using std::vector;
using std::string;

// TODO: create skybox object given gobject, shader name of cubemap texture.
//
// This function does the following:
//
// - Create a new material.
// - Assign cubemap texture to material.
// - Assign material to geometry object gobj
// - Create a new Node.
// - Assign shader to node.
// - Assign geometry object to node.
// - Set sky node in RenderState.
//
// Parameters are:
//
//   - gobj: geometry object to which assign the new material (which incluides
//           cubemap texture)
//   - skyshader: The sky shader.
//   - ctexname: The name of the cubemap texture.
//
// Useful functions:
//
//  - MaterialManager::instance()->create(const std::string & matName): create a
//    new material with name matName (has to be unique).
//  - Material::setTexture(Texture *tex): assign texture to material.
//  - GObject::setMaterial(Material *mat): assign material to geometry object.
//  - NodeManager::instance()->create(const std::string &nodeName): create a new
//    node with name nodeName (has to be unique).
//  - Node::attachShader(ShaderProgram *theShader): attach shader to node.
//  - Node::attachGobject(GObject *gobj ): attach geometry object to node.
//  - RenderState::instance()->setSkybox(Node * skynMaterialManager::instance()->create(const std::string & matName)ode): Set sky node.

void CreateSkybox(GObject *gobj,
				  ShaderProgram *skyshader,
				  const std::string &ctexname) {
	if (!skyshader) {
		fprintf(stderr, "[E] Skybox: no sky shader\n");
		exit(1);
	}
	Texture *ctex = TextureManager::instance()->find(ctexname);
	if (!ctex) {
		fprintf(stderr, "[E] Cubemap texture '%s' not found\n", ctexname.c_str());
		std::string S;
		for(auto it = TextureManager::instance()->begin();
			it != TextureManager::instance()->end(); ++it)
			S += "'"+it->getName() + "' ";
		fprintf(stderr, "...avaliable textures are: ( %s)\n", S.c_str());
		exit(1);
	}
	/* =================== PUT YOUR CODE HERE ====================== */
	//crear material
	Material *cielo=MaterialManager::instance()->create("cielo");
	//asignar textura cubica
	cielo->setTexture(ctex);
	//asignar al objeto nuestro material
	gobj->setMaterial(cielo);
	//crear el nuevo nodo
	Node *nodoCielo=NodeManager::instance()->create("nodoCielo");
	//le asignamos nuestro shader
	nodoCielo->attachShader(skyshader);
	//le asignamos nuestro objeto
	nodoCielo->attachGobject(gobj);
	//guardamos nuestro nodo en el render state
	RenderState::instance()->setSkybox(nodoCielo);

	/* =================== END YOUR CODE HERE ====================== */
}

// TODO: display the skybox
//RenderState::instance()->push(RenderState::modelview)
// This function does the following:
//
// - Store previous shader
// - Move Skybox to camera location, so that it always surrounds camera.
// - Disable depth test.
// - Set skybox shader
// - Draw skybox object.
// - Restore depth test
// - Set previous shader
//
// Parameters are:
//
//   - cam: The camera to render from
//
// Useful functions:
//
// - RenderState::instance()->getShader: get current shader.
// - RenderState::instance()->setShader(ShaderProgram * shader): set shader.
// - RenderState::instance()->push(RenderState::modelview): push MODELVIEW
//   matrix.
// - RenderState::instance()->pop(RenderState::modelview): pop MODELVIEW matrix.
// - Node::getShader(): get shader attached to node.
// - Node::getGobject(): get geometry object from node.
// - GObject::draw(): draw geometry object.
// - glDisable(GL_DEPTH_TEST): disable depth testing.
// - glEnable(GL_DEPTH_TEST): disable depth testing.

void DisplaySky(Camera *cam) {

	RenderState *rs = RenderState::instance();

	Node *skynode = rs->getSkybox();
	if (!skynode) return;

	/* =================== PUT YOUR CODE HERE ====================== */
	//guardamos el shader anterior
	//ShaderProgram *shaderAnterior=rs->getShader();
	rs->push(RenderState::modelview);
	//movemos el nodo sky a la posicion de la camara
	Trfm3D trans=Trfm3D();
	trans.addTrans(cam->getPosition());
	rs->addTrfm(RenderState::modelview,&trans);
	
	//deshabilitar z buffer
	glDisable(GL_DEPTH_TEST);
	//hacer que el shader sea el del cielo
	rs->setShader(skynode->getShader());
	//dibujar el objeto
	skynode->getGobject()->draw();
	//habilitar z buffer
	glEnable(GL_DEPTH_TEST);
	rs->pop(RenderState::modelview);
	/* =================== END YOUR CODE HERE ====================== */
}
