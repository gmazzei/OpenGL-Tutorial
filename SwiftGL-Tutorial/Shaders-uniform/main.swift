import CGLFW3
import SGLOpenGL
import Darwin.C

let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600

// Shaders
let vertexShaderSource = """
#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec3 color;
out vec4 vertexColor;

void main() {
    gl_Position = vec4(position, 1.0);
    vertexColor = vec4(0.5f, 0.0f, 0.0f, 1.0f);
}
"""

let fragmentShaderSource = """
#version 330 core

out vec4 color;
in vec4 vertexColor;
uniform vec4 ourColor;

void main() {
    color = ourColor;
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
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0,
        0.0,  0.5, 0.0
    ]
    
    // Vertex array object
    var VBO: GLuint = 0, VAO: GLuint = 0
    glGenVertexArrays(n: 1, arrays: &VAO)
    defer { glDeleteVertexArrays(1, &VAO) }
    glGenBuffers(n: 1, buffers: &VBO)
    defer { glDeleteBuffers(1, &VBO) }
    
    glBindVertexArray(VAO)
    
    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO)
    glBufferData(target: GL_ARRAY_BUFFER,
                 size: MemoryLayout<GLfloat>.stride * vertices.count,
                 data: vertices, usage: GL_STATIC_DRAW)
    
    
    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT,
                          normalized: false, stride: GLsizei(MemoryLayout<GLfloat>.stride * 3),
                          pointer: nil)
    glEnableVertexAttribArray(0)
    
    glBindVertexArray(0)
    
    
    
    // Window escape
    while glfwWindowShouldClose(window) == GL_FALSE {
        glfwPollEvents()
        
        glClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        
        glUseProgram(shaderProgram)
        
        let timeValue = glfwGetTime()
        let greenValue = (sin(timeValue) / 2) + 0.5
        let vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor")
        glUniform4f(vertexColorLocation, 0.0, Float(greenValue), 0.0, 1.0)
        
        glBindVertexArray(VAO)
        glDrawArrays(GL_TRIANGLES, 0, 3)
        glBindVertexArray(0)
        
        glfwSwapBuffers(window)
    }
    
}

main()
