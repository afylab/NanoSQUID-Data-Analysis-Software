function [Output] = GaussFilter(z, winsize)
H = [gausswin(winsize) , gausswin(winsize), gausswin(winsize)];
H = H./sum(sum(H));
Output = filter2(H,z);
end