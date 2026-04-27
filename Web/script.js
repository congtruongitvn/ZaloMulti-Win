// Hiệu ứng cuộn mượt cho các liên kết anchor
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const targetId = this.getAttribute('href');
        if (targetId === '#') return;
        
        const targetElement = document.querySelector(targetId);
        if (targetElement) {
            e.preventDefault();
            targetElement.scrollIntoView({
                behavior: 'smooth'
            });
        }
    });
});

// Hiệu ứng Navbar đổi màu khi cuộn
window.addEventListener('scroll', () => {
    const nav = document.querySelector('nav');
    if (window.scrollY > 50) {
        nav.style.background = 'rgba(0, 0, 0, 0.9)';
        nav.style.padding = '15px 10%';
    } else {
        nav.style.background = 'rgba(0, 0, 0, 0.8)';
        nav.style.padding = '20px 10%';
    }
});
