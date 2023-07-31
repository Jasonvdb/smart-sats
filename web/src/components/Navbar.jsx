import Nav from 'react-bootstrap/Nav';
import Navbar from 'react-bootstrap/Navbar';
import NavDropdown from 'react-bootstrap/NavDropdown';
import Container from 'react-bootstrap/Container';

const NavBar = () => {
    const reset = () => {
        localStorage.removeItem("token");
        window.location.reload();
    }
    return (
        <Navbar bg="primary" data-bs-theme="dark">
            <Container>
                <Navbar.Brand href="#home">Cheap Web Dev Agent</Navbar.Brand>
                <Nav className="end" onClick={reset}>
                    Reset
                </Nav>
            </Container>
        </Navbar>
    );
}

export default NavBar;
