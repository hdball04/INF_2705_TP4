#version 410

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;


uniform mat4 matrProj;

uniform int texnumero;

layout (std140) uniform varsUnif
{
    float tempsDeVieMax;       // temps de vie maximal (en secondes)
    float temps;               // le temps courant dans la simulation (en secondes)
    float dt;                  // intervalle entre chaque affichage (en secondes)
    float gravite;             // gravité utilisée dans le calcul de la position de la particule
    float pointsize;           // taille des points (en pixels)
};

in Attribs {
    vec4 couleur;
    float tempsDeVieRestant;
    //float sens; // du vol (partie 3)
    //float hauteur; // de la particule dans le repère du monde (partie 3)
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsOut;

// la hauteur minimale en-dessous de laquelle les lutins ne tournent plus (partie 3)
const float hauteurVol = 8.0;

void main()
{
    // créer 4 coins pour le panneau, à partir du point
    vec2 coins[4];
    coins[0] = vec2( -0.5,  0.5 );
    coins[1] = vec2( -0.5, -0.5 );
    coins[2] = vec2(  0.5,  0.5 );
    coins[3] = vec2(  0.5, -0.5 );

    for ( int i = 0 ; i < 4 ; ++i )
    {
        float fact = gl_in[0].gl_PointSize; 
        vec2 decalage = coins[i];
        vec4 pos = vec4( gl_in[0].gl_Position.xy + fact * decalage, gl_in[0].gl_Position.zw );

        // assigner la position du point
        gl_Position = matrProj * pos;

        // assigner la couleur courante
        AttribsOut.couleur = AttribsIn[0].couleur;

        // générer des coordonées de textures
        AttribsOut.texCoord = coins[i] + vec2( 0.5, 0.5 ); // on utilise coins[] pour définir des coordonnées de texture

        if ( texnumero == 1)
        {
            const float nlutins = 20.0; // 20 positions de vol dans la texture
            int num = int ( mod( 12.0 * AttribsIn[0].tempsDeVieRestant , nlutins ) ); // 12 Hz
            AttribsOut.texCoord.s = ( AttribsOut.texCoord.s + num ) / nlutins ;
        }

        if ( texnumero == 2)
        {
            float angle = 4.0 * AttribsIn[0].tempsDeVieRestant;
            mat2 matrix = mat2(cos(angle),-sin(angle),
                                sin(angle),cos(angle));
            vec2 vec = vec2(0.5, 0.5);
            AttribsOut.texCoord.st = (AttribsOut.texCoord.st - vec) * matrix + vec;
        }

        EmitVertex();
    }
    
}
