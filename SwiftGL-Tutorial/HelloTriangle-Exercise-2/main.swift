import CGLFW3
import SGLOpenGL

let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600

// Shaders
let vertexShaderSource = "#version 330 core\n" +
    "layout (location = 0) in vec3 position;\n" +
    "void main()\n" +
    "{\n" +
    "gl_Position = vec4(position.x, position.y, position.z, 1.0);\n" +
"}\n"
let fragmentShaderSource = "#version 330 core\n" +
    "out vec4 color;\n" +
    "void main()\n" +
    "{\n" +
    "color = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n" +
"}\n"

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
    let vertices: [[GLfloat]] = [
        // First triangle
        [-1.0, -0.5, 0.0,
        0.0, -0.5, 0.0,
        -0.5,  0.5, 0.0],
        // Second triangle
        [0.0, -0.5, 0.0,
        1.0, -0.5, 0.0,
        0.5,  0.5, 0.0]
    ]
    
    var VAO: [GLuint] = [0, 0]
    defer {
        for i in 0..<vertices.count {
            glDeleteVertexArrays(1, &VAO[i])
        }
    }
    
    var VBO: [GLuint] = [0, 0]
    defer {
        for i in 0..<vertices.count {
            glDeleteBuffers(1, &VBO[i])
        }
    }
    
    for i in 0..<vertices.count {
        glGenVertexArrays(n: 1, arrays: &VAO[i])
        glGenBuffers(n: 1, buffers: &VBO[i])
        
        glBindVertexArray(VAO[i])
        
        glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO[i])
        glBufferData(target: GL_ARRAY_BUFFER,
                     size: MemoryLayout<GLfloat>.stride * vertices[i].count,
                     data: vertices[i], usage: GL_STATIC_DRAW)
        
        
        glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT,
                              normalized: false,
                              stride: GLsizei(MemoryLayout<GLfloat>.stride * 3),
                              pointer: nil)
        glEnableVertexAttribArray(0)
        
        glBindVertexArray(0)
    }
    
    // Window escape
    while glfwWindowShouldClose(window) == GL_FALSE {
        glfwPollEvents()
        
        glClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        
        glUseProgram(shaderProgram)
        
        for i in 0..<vertices.count {
            glBindVertexArray(VAO[i])
            glDrawArrays(GL_TRIANGLES, 0, 3)
            glBindVertexArray(0)
        }
        
        glfwSwapBuffers(window)
    }
    
}

main()
