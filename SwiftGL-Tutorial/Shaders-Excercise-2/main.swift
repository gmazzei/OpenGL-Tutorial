import CGLFW3
import SGLOpenGL
import Darwin.C

let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600

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
    
    let ourShader = Shader(vertexFile: "basic.vs", fragmentFile: "basic.frag")
    
    // Input
    let vertices:[GLfloat] = [
        0.5, -0.5, 0.0,     1.0, 0.0, 0.0,  // Bottom Right
        -0.5, -0.5, 0.0,    0.0, 1.0, 0.0,  // Bottom Left
        0.0,  0.5, 0.0,     0.0, 0.0, 1.0   // Top
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
    
    // Position attribute
    let pointer0offset = UnsafeRawPointer(bitPattern: 0)
    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT,
                          normalized: false,
                          stride: GLsizei(MemoryLayout<GLfloat>.stride * 6),
                          pointer: pointer0offset)
    glEnableVertexAttribArray(0)
    
    // Color attribute
    let pointer1offset = UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.stride * 3)
    glVertexAttribPointer(index: 1, size: 3, type: GL_FLOAT,
                          normalized: false,
                          stride: GLsizei(MemoryLayout<GLfloat>.stride * 6),
                          pointer: pointer1offset)
    glEnableVertexAttribArray(1)
    
    glBindVertexArray(0)
    
    
    
    // Window escape
    while glfwWindowShouldClose(window) == GL_FALSE {
        glfwPollEvents()
        
        glClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        
        ourShader.use()
        
        glBindVertexArray(VAO)
        glDrawArrays(GL_TRIANGLES, 0, 3)
        glBindVertexArray(0)
        
        glfwSwapBuffers(window)
    }
    
}

main()
