import CGLFW3
import SGLOpenGL

// Window size
let WIDTH: GLsizei = 800, HEIGHT: GLsizei = 600

// Shader sources (written in GLSL)
let vertexShaderSource = """
#version 330 core

layout (location = 0) in vec3 position;

void main() {
    gl_Position = vec4(position.x, position.y, position.z, 1.0);
}
"""

let fragmentShaderSource = """
#version 330 core

out vec4 color;

void main() {
    color = vec4(1.0f, 0.5f, 0.2f, 1.0f);
}
"""

func keyCallback(window: OpaquePointer!, key: Int32, scancode: Int32, action: Int32, mode: Int32) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE)
    }
}

func main() {
    print("Starting GLFW context, OpenGL 3.3")
    
    glfwInit()
    defer { glfwTerminate() }
    
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE)
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE)
    
    // Windox creation
    let window = glfwCreateWindow(WIDTH, HEIGHT, "LearnSwiftGL", nil, nil)
    glfwMakeContextCurrent(window)
    guard window != nil else {
        print("Failed to create GLFW window")
        return
    }
    
    glfwSetKeyCallback(window, keyCallback)
    
    glViewport(x: 0, y: 0, width: WIDTH, height: HEIGHT)
    
    // Vertex Shader
    let vertexShader = glCreateShader(type: GL_VERTEX_SHADER)
    vertexShaderSource.withCString {
        var s = [$0]
        glShaderSource(shader: vertexShader, count: 1, string: &s, length: nil)
    }
    glCompileShader(vertexShader)
    
    var success:GLint = 0
    var infoLog = [GLchar](repeating: 0, count: 512)
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success)
    guard success == GL_TRUE else {
        glGetShaderInfoLog(vertexShader, 512, nil, &infoLog)
        fatalError(String(cString:infoLog))
    }
    
    // Fragment Shader
    let fragmentShader = glCreateShader(type: GL_FRAGMENT_SHADER)
    fragmentShaderSource.withCString {
        var s = [$0]
        glShaderSource(shader: fragmentShader, count: 1, string: &s, length: nil)
    }
    glCompileShader(fragmentShader)
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success)
    guard success == GL_TRUE else {
        glGetShaderInfoLog(fragmentShader, 512, nil, &infoLog)
        fatalError(String(cString:infoLog))
    }
    
    // Program
    let shaderProgram:GLuint = glCreateProgram()
    glAttachShader(shaderProgram, vertexShader)
    glAttachShader(shaderProgram, fragmentShader)
    glLinkProgram(shaderProgram)
    
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success)
    guard success == GL_TRUE else
    {
        glGetProgramInfoLog(shaderProgram, 512, nil, &infoLog)
        fatalError(String(cString:infoLog))
    }
    
    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)
    
    // Input
    let vertices:[GLfloat] = [
        0.5,  0.5, 0.0,  // Top Right
        0.5, -0.5, 0.0,  // Bottom Right
        -0.5, -0.5, 0.0,  // Bottom Left
        -0.5,  0.5, 0.0   // Top Left
    ]
    let indices:[GLuint] = [  // Note that we start from 0!
        0, 1, 3,  // First Triangle
        1, 2, 3   // Second Triangle
    ]
    
    // Creating buffer objects
    var VBO: GLuint = 0, VAO: GLuint = 0, EBO: GLuint = 0
    glGenVertexArrays(n: 1, arrays: &VAO)
    defer { glDeleteVertexArrays(1, &VAO) }
    glGenBuffers(n: 1, buffers: &VBO)
    defer { glDeleteBuffers(1, &VBO) }
    glGenBuffers(n: 1, buffers: &EBO)
    defer { glDeleteBuffers(1, &EBO) }
    
    glBindVertexArray(VAO)
    
    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO)
    glBufferData(target: GL_ARRAY_BUFFER,
                 size: MemoryLayout<GLfloat>.stride * vertices.count,
                 data: vertices, usage: GL_STATIC_DRAW)
    
    glBindBuffer(target: GL_ELEMENT_ARRAY_BUFFER, buffer: EBO)
    glBufferData(target: GL_ELEMENT_ARRAY_BUFFER,
                 size: MemoryLayout<GLuint>.stride * indices.count,
                 data: indices, usage: GL_STATIC_DRAW)
    
    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT,
                          normalized: false, stride: GLsizei(MemoryLayout<GLfloat>.stride * 3),
                          pointer: nil)
    glEnableVertexAttribArray(0)

    glBindVertexArray(0)
    
    // Window starts listening to escape key
    while glfwWindowShouldClose(window) == GL_FALSE {
        glfwPollEvents()
        
        glClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        
        glUseProgram(shaderProgram)
        glBindVertexArray(VAO)
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)
        glBindVertexArray(0)
        
        glfwSwapBuffers(window)
    }
    
}

main()
